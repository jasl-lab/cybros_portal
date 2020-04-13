# frozen_string_literal: true

class Report::GroupWorkloadingsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? && params[:in_iframe].blank? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? && params[:in_iframe].blank? }
  after_action :cors_set_access_control_headers, if: -> { params[:in_iframe].present? }
  after_action :verify_authorized

  def show
    authorize Bi::WorkHoursCountOrg
    current_user_companies = current_user.user_company_names

    @all_month_names = policy_scope(Bi::WorkHoursCountOrg).all_month_names
    @begin_month_name = params[:begin_month_name]&.strip || @all_month_names.first
    @end_month_name = params[:end_month_name]&.strip || @all_month_names.first
    beginning_of_month = Date.parse(@begin_month_name).beginning_of_month
    end_of_month = Date.parse(@end_month_name).end_of_month
    @view_orgcode_sum = params[:view_orgcode_sum] == "true"

    data = policy_scope(Bi::WorkHoursCountOrg)
      .where(date: beginning_of_month..end_of_month)
      .where('ORG_ORDER.org_order is not null')
      .order('ORG_ORDER.org_order DESC')

    data = if @view_orgcode_sum
      data
        .select("orgname, orgcode_sum orgcode, org_order, SUM(date_real) date_real, SUM(date_need) date_need, SUM(blue_print_real) blue_print_real, SUM(blue_print_need) blue_print_need, SUM(construction_real) construction_real, SUM(construction_need) construction_need")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = WORK_HOURS_COUNT_ORG.orgcode_sum")
        .group(:orgcode_sum, :orgname, :org_order)
    else
      data
        .select("orgname, orgcode, org_order, SUM(date_real) date_real, SUM(date_need) date_need, SUM(blue_print_real) blue_print_real, SUM(blue_print_need) blue_print_need, SUM(construction_real) construction_real, SUM(construction_need) construction_need")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = WORK_HOURS_COUNT_ORG.orgcode")
        .group(:orgcode, :orgname, :org_order)
    end

    job_data = data.having("SUM(date_real) > 0")
    blue_print_data = data.having("SUM(blue_print_real)")
    construction_data = data.having("SUM(construction_real) > 0")
    @job_company_or_department_names = job_data.collect(&:orgname).collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }
    @blue_print_company_or_department_names = blue_print_data.collect(&:orgname).collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }
    @construction_company_or_department_names = construction_data.collect(&:orgname).collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }

    @day_rate = job_data.collect { |d| ((d.date_real / d.date_need.to_f) * 100).round(0) rescue 0 }
    @day_rate_ref = params[:day_rate_ref] || 95

    @planning_day_rate = blue_print_data.collect { |d| ((d.blue_print_real / d.blue_print_need.to_f) * 100).round(0) rescue 0 }
    @planning_day_rate_ref = params[:planning_day_rate_ref] || 95

    @building_day_rate = construction_data.collect { |d| ((d.construction_real / d.construction_need.to_f) * 100).round(0) rescue 0 }
    @building_day_rate_ref = params[:building_day_rate_ref] || 80

    @current_user_companies_short_names = current_user_companies.collect { |c| Bi::OrgShortName.company_short_names.fetch(c, c) }
  end

  def export
    authorize Bi::WorkHoursCountOrg

    respond_to do |format|
      format.csv do
        render_csv_header 'Group Workloadings'
        csv_res = CSV.generate do |csv|
          csv << ['ID', '日期', '公司', '天数需填', '天数实填', '方案需填', '方案实填', '施工图需填', '施工图实填']
          policy_scope(Bi::WorkHoursCountOrg).order(id: :asc).find_each do |s|
            values = []
            values << s.id
            values << s.date
            values << s.orgname
            values << s.date_need
            values << s.date_real
            values << s.blue_print_need
            values << s.blue_print_real
            values << s.construction_need
            values << s.construction_real
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF#{csv_res}"
      end
    end
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t("layouts.sidebar.application.header"),
        link: root_path },
      { text: t("layouts.sidebar.operation.header"),
        link: report_operation_path },
      { text: t("layouts.sidebar.operation.group_workloading"),
        link: report_group_workloading_path }]
    end


    def set_page_layout_data
      @_sidebar_name = "operation"
    end
end
