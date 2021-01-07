# frozen_string_literal: true

class Report::ContractSignDetailsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    authorize Bi::ContractSignDetailDate
    prepare_meta_tags title: t('.title')
    @all_month_names = policy_scope(Bi::ContractSignDetailDate).all_month_names
    @month_name = params[:month_name]&.strip
    if @month_name.present?
      @beginning_of_month = Date.parse(@month_name).beginning_of_month
      @end_of_month = Date.parse(@month_name).end_of_month
    end
    all_org_long_names = policy_scope(Bi::ContractSignDetailDate).all_org_long_names
    all_org_short_names = all_org_long_names.collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }
    @all_org_names = all_org_short_names.zip(all_org_long_names)
    @org_name = params[:org_name]&.strip
    @all_province_names = policy_scope(Bi::ContractSignDetailDate).all_province_names
    @province_names = params[:progs].presence || []
    @date_1_great_than = params[:date_1_great_than] || 100
    @days_to_min_timecard_fill_great_than = params[:days_to_min_timecard_fill_great_than] || 100
    @can_hide_item = pundit_user.roles.pluck(:report_reviewer).any?
    @show_hide_item = params[:show_hide_item] == 'true' && @can_hide_item

    respond_to do |format|
      contract_sign_detail_datatable = ContractSignDetailDatatable.new(params,
          contract_sign_detail_dates: policy_scope(Bi::ContractSignDetailDate),
          org_name: @org_name,
          province_names: @province_names,
          beginning_of_month: @beginning_of_month,
          end_of_month: @end_of_month,
          date_1_great_than: @date_1_great_than.to_i,
          show_hide: @show_hide_item,
          view_context: view_context)
      format.html
      format.json do
        render json: contract_sign_detail_datatable
      end
      format.csv do
        render_csv_header '已归档合同签约周期明细'
        csv_res = CSV.generate do |csv|
          csv << [
            I18n.t('report.contract_sign_details.show.table.org_name'),
            I18n.t('report.contract_sign_details.show.table.dept_name'),
            I18n.t('report.contract_sign_details.show.table.business_director_name'),
            I18n.t('report.contract_sign_details.show.table.sales_contract_code'),
            I18n.t('report.contract_sign_details.show.table.sales_contract_name'),
            I18n.t('report.contract_sign_details.show.table.first_party_name'),
            I18n.t('report.contract_sign_details.show.table.amount_total'),
            I18n.t('report.contract_sign_details.show.table.date_1'),
            I18n.t('report.contract_sign_details.show.table.date_2'),
            I18n.t('report.contract_sign_details.show.table.contract_time'),
            I18n.t('report.contract_sign_details.show.table.min_timecard_fill'),
            I18n.t('report.contract_sign_details.show.table.min_date_hrcost_amount'),
            I18n.t('report.contract_sign_details.show.table.project_type'),
          ]
          contract_sign_detail_datatable.get_raw_records.each do |r|
            values = []
            values << Bi::OrgShortName.company_short_names.fetch(r.orgname, r.orgname)
            values << r.deptname
            values << r.businessdirectorname
            values << r.salescontractcode
            values << r.salescontractname

            values << r.firstpartyname
            values << r.amounttotal
            values << r.date1
            values << r.date2
            values << r.filingtime

            values << r.mintimecardfill
            values << r.mindatehrcostamount
            values << r.projecttype
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF#{csv_res}"
      end
    end
  end

  def hide
    authorize Bi::ContractSignDetailDate
    contract_code = params[:contract_code]
    policy_scope(Bi::ContractSignDetailDate).where(salescontractcode: contract_code).update_all(need_hide: true)
    redirect_to report_contract_sign_detail_path
  end

  def un_hide
    authorize Bi::ContractSignDetailDate
    contract_code = params[:contract_code]
    policy_scope(Bi::ContractSignDetailDate).where(salescontractcode: contract_code).update_all(need_hide: nil)
    redirect_to report_contract_sign_detail_path(show_hide_item: true)
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.contract_sign_detail'),
        link: report_contract_sign_detail_path }]
    end

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
