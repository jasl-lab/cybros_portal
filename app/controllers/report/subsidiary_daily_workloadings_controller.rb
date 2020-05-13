class Report::SubsidiaryDailyWorkloadingsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    authorize Bi::WorkHoursDayCountDept
    @begin_date = params[:begin_date]&.strip || Time.now.beginning_of_month
    @end_date = params[:end_date]&.strip || Time.now.end_of_day
    beginning_of_day = Date.parse(@begin_date).beginning_of_day unless @begin_date.is_a?(Time)
    end_of_day = Date.parse(@end_date).end_of_day unless @end_date.is_a?(Time)
    @short_company_name = params[:company_name].presence || current_user.user_company_short_name
    @company_short_names = policy_scope(Bi::WorkHoursDayCountDept).select(:orgcode)
      .distinct.where(date: beginning_of_day..end_of_day).collect { |r| Bi::OrgShortName.company_short_names_by_orgcode.fetch(r.orgcode, r.orgcode) }
    @job_company_or_department_names = []
  end

  def export
    authorize Bi::WorkHoursDayCountDept
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.group_workloading'),
        link: report_group_workloading_path(view_orgcode_sum: true) },
      { text: t('layouts.sidebar.operation.subsidiary_workloading'),
        link: report_subsidiary_workloading_path },
      { text: t('layouts.sidebar.operation.subsidiary_daily_workloading'),
        link: report_subsidiary_daily_workloading_path }
      ]
    end


    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
