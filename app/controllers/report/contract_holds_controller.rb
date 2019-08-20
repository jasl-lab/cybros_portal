# frozen_string_literal: true

class Report::ContractHoldsController < Report::BaseController
  before_action :authenticate_user!, unless: -> { params[:in_iframe].present? }, only: [:show]
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }

  def show
    @all_month_names = policy_scope(Bi::ContractHold).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.last
    end_of_month = Date.parse(@month_name).end_of_month
    @last_available_date = policy_scope(Bi::ContractHold).where("date <= ?", end_of_month).order(date: :desc).first.date

    data = policy_scope(Bi::ContractHold)
      .where(date: @last_available_date)
      .joins("INNER JOIN SH_REPORT_DEPT_ORDER on SH_REPORT_DEPT_ORDER.deptcode = CONTRACT_HOLD.deptcode")
      .select("CONTRACT_HOLD.deptcode, SH_REPORT_DEPT_ORDER.dept_asc, SUM(busiretentcontract) busiretentcontract, SUM(busiretentnocontract) busiretentnocontract")
      .group("CONTRACT_HOLD.deptcode, SH_REPORT_DEPT_ORDER.dept_asc")
      .order("SH_REPORT_DEPT_ORDER.dept_asc")

    all_business_ltd_codes = data.collect(&:deptcode)
    @only_have_data_dept = (Bi::ShReportDeptOrder.all_deptcodes_in_order & all_business_ltd_codes)

    @deptnames_in_order = @only_have_data_dept.collect do |c|
      long_name = Bi::PkCodeName.mapping2deptcode.fetch(c, c)
      Bi::StaffCount.company_short_names.fetch(long_name, long_name)
    end

    @biz_retent_contract = @only_have_data_dept.collect do |dept_code|
      d = data.find { |c| c.deptcode == dept_code }
      (d.busiretentcontract / 10000.to_f).round(0)
    end

    @biz_retent_no_contract = @only_have_data_dept.collect do |dept_code|
      d = data.find { |c| c.deptcode == dept_code }
      (d.busiretentnocontract.to_f / 10000.to_f).round(0)
    end

    @biz_retent_totals = @biz_retent_contract.zip(@biz_retent_no_contract).map { |d| d[0] + d[1] }

    this_month_staff_data = month_staff_data(end_of_month)

    @dept_avg_staff = @only_have_data_dept.collect do |dept_code|
      d = this_month_staff_data.find { |c| c.deptcode == dept_code }
      d.avgamount
    end
    @biz_retent_totals_per_dept = @biz_retent_totals.zip(@dept_avg_staff).map do |d|
      (d[0] / d[1]).to_f.round(0) rescue 0
    end

    @biz_retent_totals_sum = @biz_retent_contract.sum()
    avg_staff_per_company = this_month_staff_data.reduce({}) do |h, d|
      h[d.deptname] = d.avgamount
      h
    end
    @biz_retent_totals_sum_per_staff = @biz_retent_totals_sum /
      (@deptnames_in_order.inject(0) do |sum, deptname|
        sum += avg_staff_per_company.fetch(deptname, 0)
        sum
      end).to_f
  end

  def unsign_detail_drill_down
    @department_name = params[:department_name]
    dept_code = params[:department_code]
    @drill_down_subtitle = t(".subtitle")
    end_of_month = Date.parse(params[:month_name]).end_of_month
    last_available_date = policy_scope(Bi::ContractHoldUnsignDetail).where("date <= ?", end_of_month).order(date: :desc).first.date
    @unsigned_data = policy_scope(Bi::ContractHoldUnsignDetail).where(date: last_available_date, deptcode: dept_code)

    render
  end

  def export_unsign_detail
    authorize Bi::ContractHoldUnsignDetail
    end_of_month = Date.parse(params[:month_name]).end_of_month
    last_available_date = policy_scope(Bi::ContractHoldUnsignDetail).where("date <= ?", end_of_month).order(date: :desc).first.date

    respond_to do |format|
      format.csv do
        render_csv_header "Unsign #{last_available_date.to_date} details"
        csv_res = CSV.generate do |csv|
          csv << [
            t("report.contract_holds.show.table.deptname"),
            t("report.contract_holds.show.table.projectitemcode"),
            t("report.contract_holds.show.table.projectitemname"),
            t("report.contract_holds.show.table.contractcode"),
            t("report.contract_holds.show.table.contractname"),
            t("report.contract_holds.show.table.profession"),
            t("report.contract_holds.show.table.planning_output"),
            t("report.contract_holds.show.table.workhour_cost"),
            t("report.contract_holds.show.table.unsign_hold_value")
          ]
          policy_scope(Bi::ContractHoldUnsignDetail).where(date: last_available_date).find_each do |r|
            values = []
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
        send_data "\xEF\xBB\xBF#{csv_res}"
      end
    end
  end

  def sign_detail_drill_down
    @department_name = params[:department_name]
    dept_code = params[:department_code]
    @drill_down_subtitle = t(".subtitle")
    end_of_month = Date.parse(params[:month_name]).end_of_month
    last_available_date = policy_scope(Bi::ContractHoldSignDetail).where("date <= ?", end_of_month).order(date: :desc).first.date
    @signed_data = policy_scope(Bi::ContractHoldSignDetail).where(date: last_available_date, deptcode: dept_code)
    render
  end

  def export_sign_detail
    authorize Bi::ContractHoldSignDetail
    end_of_month = Date.parse(params[:month_name]).end_of_month
    last_available_date = policy_scope(Bi::ContractHoldSignDetail).where("date <= ?", end_of_month).order(date: :desc).first.date

    respond_to do |format|
      format.csv do
        render_csv_header "Sign #{last_available_date.to_date} details"
        csv_res = CSV.generate do |csv|
          csv << [
            t("report.contract_holds.show.table.deptname"),
            t("report.contract_holds.show.table.projectitemcode"),
            t("report.contract_holds.show.table.projectitemname"),
            t("report.contract_holds.show.table.contractcode"),
            t("report.contract_holds.show.table.contractname"),
            t("report.contract_holds.show.table.profession"),
            t("report.contract_holds.show.table.output"),
            t("report.contract_holds.show.table.milestone"),
            t("report.contract_holds.show.table.sign_hold_value")
          ]
          policy_scope(Bi::ContractHoldSignDetail).where(date: last_available_date).find_each do |r|
            values = []
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
        send_data "\xEF\xBB\xBF#{csv_res}"
      end
    end
  end


  private

    def month_staff_data(end_of_month)
      d = Bi::ShStaffCount.where(f_month: end_of_month.to_s(:short_month))
      if d.blank?
        d = Bi::ShStaffCount.where(f_month: Bi::ShStaffCount.last_available_f_month)
      end
      d
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.report.header"),
        link: report_root_path },
      { text: t("layouts.sidebar.report.contract_hold"),
        link: report_contract_hold_path }]
    end

    def set_page_layout_data
      @_sidebar_name = "report"
    end
end
