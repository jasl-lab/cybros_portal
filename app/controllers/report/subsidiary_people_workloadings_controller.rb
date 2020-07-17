class Report::SubsidiaryPeopleWorkloadingsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    authorize Bi::WorkHoursCountCombine
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
    @view_deptcode_sum = params[:view_deptcode_sum] == 'true'
    @selected_company_code = params[:company_code].presence || current_user.can_access_org_codes.first || current_user.user_company_orgcode
    @short_company_name = if params[:company_name].present?
      @selected_company_code = Bi::OrgShortName.org_code_by_short_name.fetch(params[:company_name], params[:company_name])
      params[:company_name]
    else
      Bi::OrgShortName.company_short_names_by_orgcode.fetch(@selected_company_code, @selected_company_code)
    end

    @company_short_names = policy_scope(Bi::WorkHoursCountCombine).select(:orgcode)
      .distinct.where(date: beginning_of_day..end_of_day).collect do |r|
        [Bi::OrgShortName.company_short_names_by_orgcode.fetch(r.orgcode, r.orgcode), r.orgcode]
      end

    dept_short_names = policy_scope(Bi::WorkHoursCountCombine)
      .distinct.where(date: beginning_of_day..end_of_day).where(orgcode: @selected_company_code)
    @dept_short_names = if @view_deptcode_sum
      dept_short_names.select('deptcode_sum deptcode')
    else
      dept_short_names.select(:deptcode)
    end.collect { |r| [Bi::PkCodeName.mapping2deptcode.fetch(r.deptcode, r.deptcode), r.deptcode] }
    @selected_dept_code = params[:dept_code].presence || @dept_short_names.first.second

    data = policy_scope(Bi::WorkHoursCountCombine)
      .select('userid, ncworkno, username, profession, SUM(type1) type1, SUM(type2) type2, SUM(type4) type4, SUM(needhours) needhours')
      .where(date: beginning_of_day..end_of_day, orgcode: @selected_company_code)
      .order(:userid, :ncworkno, :username, :profession)
      .group(:userid, :ncworkno, :username, :profession)
    @data = if @view_deptcode_sum
      data.where(deptcode_sum: @selected_dept_code)
    else
      data.where(deptcode: @selected_dept_code)
    end

    fill_rate_numerator = policy_scope(Bi::WorkHoursCountCombine)
      .select('userid, COUNT(*) realhours_count')
      .where(date: beginning_of_day..end_of_day, orgcode: @selected_company_code)
      .where('type1 > 0 OR type2 > 0 OR type4 > 0 ')
      .group(:userid)
    @fill_rate_numerator = if @view_deptcode_sum
      fill_rate_numerator.where(deptcode_sum: @selected_dept_code)
    else
      fill_rate_numerator.where(deptcode: @selected_dept_code)
    end.reduce({}) do |h, s|
      h[s.userid] = s.realhours_count
      h
    end

    fill_rate_denominator = policy_scope(Bi::WorkHoursCountCombine)
      .select('userid, COUNT(needhours) needhours_count')
      .where(date: beginning_of_day..end_of_day, orgcode: @selected_company_code)
      .where('needhours > 0')
      .group(:userid)
    @fill_rate_denominator = if @view_deptcode_sum
      fill_rate_denominator.where(deptcode_sum: @selected_dept_code)
    else
      fill_rate_denominator.where(deptcode: @selected_dept_code)
    end.reduce({}) do |h, s|
      h[s.userid] = s.needhours_count
      h
    end
  end

  def fill_dept_short_names
    view_deptcode_sum = params[:view_deptcode_sum] == 'true'
    beginning_of_day = Date.parse(params[:begin_date]).beginning_of_day
    end_of_day = Date.parse(params[:end_date]).end_of_day

    dept_short_names = policy_scope(Bi::WorkHoursCountCombine)
      .distinct.where(date: beginning_of_day..end_of_day).where(orgcode: params[:company_code])
    @dept_short_names = if view_deptcode_sum
      dept_short_names.select('deptcode_sum deptcode')
    else
      dept_short_names.select(:deptcode)
    end.collect { |r| [Bi::PkCodeName.mapping2deptcode.fetch(r.deptcode, r.deptcode), r.deptcode] }
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
        link: report_subsidiary_daily_workloading_path },
      { text: t('layouts.sidebar.operation.subsidiary_people_workloading'),
        link: report_subsidiary_people_workloading_path }
      ]
    end


    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
