# frozen_string_literal: true

class Report::GroupDailyWorkloadingsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    authorize Bi::WorkHoursDayCountOrg
    prepare_meta_tags title: t('.title')
    @begin_date = params[:begin_date]&.strip || Time.now.beginning_of_month
    @end_date = params[:end_date]&.strip || Time.now.end_of_day
    beginning_of_day = if @begin_date.is_a?(String)
      Date.parse(@begin_date).beginning_of_day
    else
      @begin_date.beginning_of_day
    end
    end_of_day = if @end_date.is_a?(String)
      Date.parse(@end_date).end_of_day
    else
      @end_date.end_of_day
    end
    @view_orgcode_sum = params[:view_orgcode_sum] == 'true'

    non_construction_company_codes = Report::BaseController::NON_CONSTRUCTION_COMPANYS
      .collect { |sn| Bi::OrgShortName.org_code_by_short_name.fetch(sn, sn) }

    data = policy_scope(Bi::WorkHoursDayCountOrg)
      .where(date: beginning_of_day..end_of_day)
      .where('ORG_ORDER.org_order is not null')
      .where("ORG_ORDER.org_type = '创意板块'")
      .order('ORG_ORDER.org_order ASC')

    data = if @view_orgcode_sum
      data
        .select('orgcode_sum orgcode, org_order, SUM(date_real) date_real, SUM(date_need) date_need, SUM(blue_print_real) blue_print_real, SUM(blue_print_need) blue_print_need, SUM(blue_print_real_unapproved) blue_print_real_unapproved, SUM(construction_real) construction_real, SUM(construction_need) construction_need, SUM(construction_real_unapproved) construction_real_unapproved, SUM(others_real) others_real, SUM(others_need) others_need, SUM(others_real_unapproved) others_real_unapproved')
        .joins('LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = WORK_HOURS_DAY_COUNT_ORG.orgcode_sum')
        .group(:orgcode_sum, :org_order)
    else
      data
        .select('orgcode, org_order, SUM(date_real) date_real, SUM(date_need) date_need, SUM(blue_print_real) blue_print_real, SUM(blue_print_need) blue_print_need, SUM(blue_print_real_unapproved) blue_print_real_unapproved, SUM(construction_real) construction_real, SUM(construction_need) construction_need, SUM(construction_real_unapproved) construction_real_unapproved, SUM(others_real) others_real, SUM(others_need) others_need, SUM(others_real_unapproved) others_real_unapproved')
        .joins('LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = WORK_HOURS_DAY_COUNT_ORG.orgcode')
        .group(:orgcode, :org_order)
    end

    job_data = data.having('SUM(date_need) > 0')
    blue_print_data = data.having('SUM(blue_print_need) > 0').where.not(orgcode: non_construction_company_codes)
    construction_data = data.having('SUM(construction_need) > 0').where.not(orgcode: non_construction_company_codes)
    non_construction_data = data.having('SUM(others_need) > 0').where(orgcode: non_construction_company_codes)
    @job_company_or_department_names = job_data.collect(&:orgcode).collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }
    @blue_print_company_or_department_names = blue_print_data.collect(&:orgcode).collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }
    @construction_company_or_department_names = construction_data.collect(&:orgcode).collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }
    @non_construction_company_or_department_names = non_construction_data.collect(&:orgcode).collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    @day_rate = job_data.collect { |d| ((d.date_real / d.date_need.to_f) * 100).round(0) rescue 0 }
    @day_rate_ref = params[:day_rate_ref] || 95

    @planning_day_unapproved_rate = blue_print_data.collect { |d| ((d.blue_print_real_unapproved / d.blue_print_need.to_f) * 100).round(0) rescue 0 }
    @planning_day_rate = blue_print_data.collect { |d| ((d.blue_print_real / d.blue_print_need.to_f) * 100).round(0) rescue 0 }
    @planning_day_rate_ref = params[:planning_day_rate_ref] || 95

    @building_day_unapproved_rate = construction_data.collect { |d| ((d.construction_real_unapproved / d.construction_need.to_f) * 100).round(0) rescue 0 }
    @building_day_rate = construction_data.collect { |d| ((d.construction_real / d.construction_need.to_f) * 100).round(0) rescue 0 }
    @building_day_rate_ref = params[:building_day_rate_ref] || 80

    @non_construction_day_unapproved_rate = non_construction_data.collect { |d| ((d.others_real_unapproved / d.others_need.to_f) * 100).round(0) rescue 0 }
    @non_construction_day_rate = non_construction_data.collect { |d| ((d.others_real / d.others_need.to_f) * 100).round(0) rescue 0 }

    @current_user_companies_short_names = current_user.user_company_short_names +
      current_user.can_access_org_codes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.group_daily_workloading'),
        link: report_group_daily_workloading_path(view_orgcode_sum: true) }
      ]
    end


    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
