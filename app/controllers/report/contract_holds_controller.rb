# frozen_string_literal: true

class Report::ContractHoldsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }

  def fill_dept_names
  end

  def show
    prepare_meta_tags title: t('.title')
    @all_month_names = policy_scope(Bi::ContractHold, :group_resolve).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    end_of_month = Date.parse(@month_name).end_of_month
    @last_available_date = policy_scope(Bi::ContractHold, :group_resolve).where('date <= ?', end_of_month).order(date: :desc).first.date
    @dept_options = params[:depts].presence
    @company_short_names = policy_scope(Bi::ContractHold, :group_resolve).available_company_names(@last_available_date)
    @selected_org_code = params[:org_code]&.strip || current_user.can_access_org_codes.first || current_user.user_company_orgcode
    @view_deptcode_sum = params[:view_deptcode_sum] == 'true'
    @selected_company_short_name = Bi::OrgShortName.company_short_names_by_orgcode.fetch(@selected_org_code, @selected_org_code)
    @selected_org_code = @selected_org_code[1..] if @selected_org_code.start_with?('H')
    data = policy_scope(Bi::ContractHold, :group_resolve)
      .where(date: @last_available_date).where(orgcode: @selected_org_code)
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'")
      .where('ORG_REPORT_DEPT_ORDER.开始时间 <= ?', @last_available_date)
      .where('ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?', @last_available_date)

    data = if @view_deptcode_sum
      data.select('CONTRACT_HOLD.deptcode_sum deptcode, ORG_REPORT_DEPT_ORDER.部门排名, SUM(busiretentcontract) busiretentcontract, SUM(busiretentnocontract) busiretentnocontract')
        .joins('INNER JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = CONTRACT_HOLD.deptcode_sum')
        .group('ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_HOLD.deptcode_sum')
        .order(Arel.sql('ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_HOLD.deptcode_sum'))
    else
      data.select('CONTRACT_HOLD.deptcode, ORG_REPORT_DEPT_ORDER.部门排名, SUM(busiretentcontract) busiretentcontract, SUM(busiretentnocontract) busiretentnocontract')
        .joins('INNER JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = CONTRACT_HOLD.deptcode')
        .group('ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_HOLD.deptcode')
        .order(Arel.sql('ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_HOLD.deptcode'))
    end

    @dept_options = if @dept_options.blank? && @view_deptcode_sum
      data_sum = policy_scope(Bi::ContractHold, :group_resolve)
        .where(date: @last_available_date).where(orgcode: @selected_org_code)
        .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where('ORG_REPORT_DEPT_ORDER.开始时间 <= ?', @last_available_date)
        .where('ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?', @last_available_date)
        .joins('INNER JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = CONTRACT_HOLD.deptcode_sum')
        .order(Arel.sql('ORG_REPORT_DEPT_ORDER.部门排名, CONTRACT_HOLD.deptcode_sum'))

      h_deptcodes = data_sum.pluck(:deptcode_sum)
      belongs_to_h_deptcodes = data_sum.where(deptcode_sum: h_deptcodes).pluck(:deptcode)
      sum_depts = data_sum.pluck(:deptcode) - belongs_to_h_deptcodes + h_deptcodes
      Bi::OrgReportDeptOrder.where(编号: sum_depts)
        .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where('ORG_REPORT_DEPT_ORDER.开始时间 <= ?', @last_available_date)
        .where('ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?', @last_available_date)
        .order(Arel.sql('ORG_REPORT_DEPT_ORDER.部门排名')).pluck(:编号)
    elsif @dept_options.blank?
      data.pluck('CONTRACT_HOLD.deptcode')
    else
      @dept_options
    end

    data = if @view_deptcode_sum
      data.where("CONTRACT_HOLD.deptcode_sum": @dept_options)
    else
      data.where("CONTRACT_HOLD.deptcode": @dept_options)
    end

    @deptnames_in_order = @dept_options.collect do |c|
      long_name = Bi::PkCodeName.mapping2deptcode.fetch(c, c)
      Bi::OrgShortName.company_short_names.fetch(long_name, long_name)
    end
    @department_options = @deptnames_in_order.zip(@dept_options)

    @biz_retent_contract = @dept_options.collect do |dept_code|
      d = data.find { |c| c.deptcode == dept_code }
      if d.present?
        (d.busiretentcontract.to_f / 10000.to_f).round(0)
      else
        0
      end
    end

    @biz_retent_no_contract = @dept_options.collect do |dept_code|
      d = data.find { |c| c.deptcode == dept_code }
      if d.present?
        (d.busiretentnocontract.to_f / 10000.to_f).round(0)
      else
        0
      end
    end

    @biz_retent_totals = @biz_retent_contract.zip(@biz_retent_no_contract).map { |d| d[0] + d[1] }

    this_month_staff_data = if @selected_org_code == '000101' && end_of_month.year < 2020
      Bi::ShStaffCount.staff_count_per_dept_code_by_date(end_of_month)
    else
      Bi::YearAvgWorker.worker_per_dept_code_by_date_and_sum(@selected_org_code, end_of_month, @view_deptcode_sum)
    end

    @dept_avg_staff = @dept_options.collect do |dept_code|
      this_month_staff_data[dept_code] || Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM
    end
    @biz_retent_totals_per_dept = @biz_retent_totals.zip(@dept_avg_staff).map do |d|
      (d[0] / d[1]).to_f.round(0) rescue 0
    end

    @biz_retent_totals_sum = @biz_retent_totals.sum()
    @sum_biz_retent_totals_staff = @biz_retent_totals.sum / @dept_avg_staff.reject { |d| d == Bi::BiLocalTimeRecord::DEFAULT_PEOPLE_NUM }.sum.to_f
  end

  def unsign_detail_drill_down
    @department_name = params[:department_name]
    dept_code = params[:department_code]
    @view_deptcode_sum = params[:view_deptcode_sum] == 'true'
    @drill_down_subtitle = t('.subtitle')
    end_of_month = Date.parse(params[:month_name]).end_of_month
    last_available_date = policy_scope(Bi::ContractHoldUnsignDetail).where('date <= ?', end_of_month).order(date: :desc).first.date
    @unsigned_data = policy_scope(Bi::ContractHoldUnsignDetail)
      .order(:projectitemcode)
    @unsigned_data = if @view_deptcode_sum
      @unsigned_data.where(date: last_available_date, deptcode_sum: dept_code)
    else
      @unsigned_data.where(date: last_available_date, deptcode: dept_code)
    end
    render
  end

  def export_unsign_detail
    authorize Bi::ContractHoldUnsignDetail
    end_of_month = Date.parse(params[:month_name]).end_of_month
    last_available_date = policy_scope(Bi::ContractHoldUnsignDetail).where('date <= ?', end_of_month).order(date: :desc).first.date
    company_short_names_by_orgcode = Bi::OrgShortName.company_short_names_by_orgcode

    respond_to do |format|
      format.csv do
        render_csv_header "Unsign #{last_available_date.to_date} details"
        csv_res = CSV.generate do |csv|
          csv << [
            t('report.contract_holds.show.table.orgname'),
            t('report.contract_holds.show.table.deptname'),
            t('report.contract_holds.show.table.projectitemcode'),
            t('report.contract_holds.show.table.projectitemname'),
            t('report.contract_holds.show.table.contractcode'),
            t('report.contract_holds.show.table.contractname'),
            t('report.contract_holds.show.table.profession'),
            t('report.contract_holds.show.table.planning_output'),
            t('report.contract_holds.show.table.workhour_cost'),
            t('report.contract_holds.show.table.unsign_hold_value')
          ]
          policy_scope(Bi::ContractHoldUnsignDetail).where(date: last_available_date).each do |r|
            values = []
            values << company_short_names_by_orgcode.fetch(r.orgcode, r.orgcode)
            values << Bi::PkCodeName.mapping2deptcode.fetch(r.deptcode, r.deptcode)
            values << r.projectitemcode
            values << r.projectitemname
            values << r.contractcode
            values << r.contractname
            values << r.profession
            values << r.planning_output&.round(0)
            values << r.workhour_cost&.round(0)
            values << r.unsign_hold_value&.round(0)
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF#{csv_res}", filename: "Unsign #{last_available_date.to_date} details.csv"
      end
    end
  end

  def sign_detail_drill_down
    @department_name = params[:department_name]
    dept_code = params[:department_code]
    @view_deptcode_sum = params[:view_deptcode_sum] == 'true'
    @drill_down_subtitle = t('.subtitle')
    end_of_month = Date.parse(params[:month_name]).end_of_month
    last_available_date = policy_scope(Bi::ContractHoldSignDetail).where('date <= ?', end_of_month).order(date: :desc).first.date
    @signed_data = policy_scope(Bi::ContractHoldSignDetail)
      .where('sign_hold_value > 0')
      .order(:projectitemcode)
    @signed_data = if @view_deptcode_sum
      @signed_data.where(date: last_available_date, deptcode_sum: dept_code)
    else
      @signed_data.where(date: last_available_date, deptcode: dept_code)
    end
    render
  end

  def export_sign_detail
    authorize Bi::ContractHoldSignDetail
    end_of_month = Date.parse(params[:month_name]).end_of_month
    last_available_date = policy_scope(Bi::ContractHoldSignDetail).where('date <= ?', end_of_month).order(date: :desc).first.date
    company_short_names_by_orgcode = Bi::OrgShortName.company_short_names_by_orgcode
    respond_to do |format|
      format.csv do
        render_csv_header "Sign #{last_available_date.to_date} details"
        csv_res = CSV.generate do |csv|
          csv << [
            t('report.contract_holds.show.table.orgname'),
            t('report.contract_holds.show.table.deptname'),
            t('report.contract_holds.show.table.projectitemcode'),
            t('report.contract_holds.show.table.projectitemname'),
            t('report.contract_holds.show.table.contractcode'),
            t('report.contract_holds.show.table.contractname'),
            t('report.contract_holds.show.table.profession'),
            t('report.contract_holds.show.table.output'),
            t('report.contract_holds.show.table.milestone'),
            t('report.contract_holds.show.table.sign_hold_value')
          ]
          policy_scope(Bi::ContractHoldSignDetail).order(:orgcode, :deptcode).where(date: last_available_date).each do |r|
            values = []
            values << company_short_names_by_orgcode.fetch(r.orgcode, r.orgcode)
            values << Bi::PkCodeName.mapping2deptcode.fetch(r.deptcode, r.deptcode)
            values << r.projectitemcode
            values << r.projectitemname
            values << r.contractcode
            values << r.contractname
            values << r.profession
            values << r.output&.round(0)
            values << (r.milestone * 100)&.round(0)
            values << r.sign_hold_value&.round(0)
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF#{csv_res}", filename: "Sign #{last_available_date.to_date} details.csv"
      end
    end
  end


  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.group_contract_hold'),
        link: report_group_contract_hold_path(view_orgcode_sum: true) },
      { text: t('layouts.sidebar.operation.contract_hold'),
        link: report_contract_hold_path(view_deptcode_sum: true) }]
    end

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
