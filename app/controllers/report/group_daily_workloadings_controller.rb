class Report::GroupDailyWorkloadingsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    authorize Bi::WorkHoursDayCountDept
    @begin_date = params[:begin_date]&.strip || Time.now.beginning_of_month
    @end_date = params[:end_date]&.strip || Time.now.end_of_day
    beginning_of_day = Date.parse(@begin_date).beginning_of_day unless @begin_date.is_a?(Time)
    end_of_day = Date.parse(@end_date).end_of_day unless @end_date.is_a?(Time)
    @view_deptcode_sum = params[:view_deptcode_sum] == 'true'

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
      { text: t('layouts.sidebar.operation.group_daily_workloading'),
        link: report_group_daily_workloading_path(view_orgcode_sum: true) }
      ]
    end


    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
