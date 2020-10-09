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
    prepare_meta_tags title: t(".title", company: @short_company_name)

    dept_short_names = policy_scope(Bi::WorkHoursCountCombine)
      .distinct.where(date: beginning_of_day..end_of_day,)
      .where(orgcode: @selected_company_code)
      .joins('INNER JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = WORK_HOURS_COUNT_COMBINE.deptcode_sum')
      .order('ORG_REPORT_DEPT_ORDER.部门排名')
    @dept_short_names = if @view_deptcode_sum
      dept_short_names.select('deptcode_sum deptcode, ORG_REPORT_DEPT_ORDER.部门排名')
    else
      dept_short_names.select('deptcode, ORG_REPORT_DEPT_ORDER.部门排名')
    end.collect { |r| [Bi::PkCodeName.mapping2deptcode.fetch(r.deptcode, r.deptcode), r.deptcode] }
    @selected_dept_code = params[:dept_code].presence || @dept_short_names.first.second
    @selected_dept_name = Bi::PkCodeName.mapping2deptname.fetch(@selected_dept_code, @selected_dept_code)

    data = policy_scope(Bi::WorkHoursCountCombine)
      .select('userid, ncworkno, username, profession, SUM(IFNULL(type1,0)) type1, SUM(IFNULL(type2,0)) type2, SUM(IFNULL(type4,0)) type4, SUM(IFNULL(needhours,0)) needhours')
      .where(date: beginning_of_day..end_of_day, orgcode: @selected_company_code)
      .order(:userid, :ncworkno, :username, :profession)
      .group(:userid, :ncworkno, :username, :profession)
    @data = if @view_deptcode_sum
      data.where(deptcode_sum: @selected_dept_code)
    else
      data.where(deptcode: @selected_dept_code)
    end

    @lunch_work_count, @lunch_non_work_count = policy_scope(Bi::WorkHoursCountCombine).lunch_count_hash(@selected_company_code, beginning_of_day, end_of_day)

    @fill_rate_numerator, @fill_rate_denominator = policy_scope(Bi::WorkHoursCountCombine).fill_rate_hash(@selected_company_code, @selected_dept_code, beginning_of_day, end_of_day, @view_deptcode_sum)

    respond_to do |format|
      format.html
      format.csv do
        render_csv_header 'subsidiary people workloading'
        csv_res = CSV.generate do |csv|
          csv << ['NC 工号', '姓名', '实填工时', '应填工时', '填报率', '饱和度', '可发放加班餐补次数', '专业']
          @data.each do |d|
            values = []
            values << d.ncworkno
            values << d.username
            values << d.type1.to_f + d.type2.to_f + d.type4.to_f
            values << d.needhours
            numerator = @fill_rate_numerator[d.userid]
            denominator = @fill_rate_denominator[d.userid]
            fr = if denominator.present?
              fill_rate = (numerator.to_f * 100 / denominator).round(1)
              (fill_rate > 100) ? 100 : fill_rate
            else
              'N/A'
            end
            values << fr
            values << ((d.type1.to_f * 100) / d.needhours.to_f).round(1)
            values << @lunch_work_count[d.userid].to_i + @lunch_non_work_count[d.userid].to_i
            values << d.profession
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF#{csv_res}"
      end
    end
  end

  def fill_dept_short_names
    view_deptcode_sum = params[:view_deptcode_sum] == 'true'
    beginning_of_day = Date.parse(params[:begin_date]).beginning_of_day
    end_of_day = Date.parse(params[:end_date]).end_of_day

    dept_short_names = policy_scope(Bi::WorkHoursCountCombine)
      .distinct.where(date: beginning_of_day..end_of_day)
      .where(orgcode: params[:company_code])
      .joins('INNER JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = WORK_HOURS_COUNT_COMBINE.deptcode_sum')
      .order('ORG_REPORT_DEPT_ORDER.部门排名')
    @dept_short_names = if view_deptcode_sum
      dept_short_names.select('deptcode_sum deptcode, ORG_REPORT_DEPT_ORDER.部门排名')
    else
      dept_short_names.select('deptcode, ORG_REPORT_DEPT_ORDER.部门排名')
    end.collect { |r| [Bi::PkCodeName.mapping2deptcode.fetch(r.deptcode, r.deptcode), r.deptcode] }
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.group_daily_workloading'),
        link: report_group_daily_workloading_path(view_deptcode_sum: true) },
      { text: t('layouts.sidebar.operation.subsidiary_daily_workloading'),
        link: report_subsidiary_daily_workloading_path(view_deptcode_sum: true) },
      { text: t('layouts.sidebar.operation.subsidiary_people_workloading'),
        link: report_subsidiary_people_workloading_path(view_deptcode_sum: true) }
      ]
    end


    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
