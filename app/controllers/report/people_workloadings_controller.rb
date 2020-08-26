class Report::PeopleWorkloadingsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    authorize Bi::WorkHoursCountCombine
    prepare_meta_tags title: t(".title")
    @ncworkno = params[:ncworkno] || current_user.clerk_code
    last_available_date = policy_scope(Bi::WorkHoursCountCombine).last_available_date
    @begin_date = params[:begin_date]&.strip || last_available_date.beginning_of_month
    @end_date = params[:end_date]&.strip || last_available_date.end_of_day

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

    months = all_months_until(beginning_of_day, end_of_day)
    @months = months.each_cons(2).to_a.append([end_of_day.beginning_of_month, end_of_day])
  end

  private

    def all_months_until(from, to)
      from, to = to, from if from > to
      m = Date.new from.year, from.month
      result = []
      while m <= to
        result << m
        m >>= 1
      end

      result
    end

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
        link: report_subsidiary_daily_workloading_path },
      { text: t('layouts.sidebar.operation.subsidiary_people_workloading'),
        link: report_subsidiary_people_workloading_path(view_deptcode_sum: true) },
      { text: t('layouts.sidebar.operation.people_workloading'),
        link: report_people_workloading_path },
      ]
    end


    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
