# frozen_string_literal: true

class Report::SubsidiaryDailyWorkloadingsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }
  before_action :set_drill_down_params_and_title,
    only: %i[day_rate_drill_down planning_day_rate_drill_down building_day_rate_drill_down],
    if: -> { request.format.js? }

  def show
    authorize Bi::WorkHoursDayCountDept
    last_available_date = policy_scope(Bi::WorkHoursDayCountDept).last_available_date
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
    prepare_meta_tags title: t('.title', company: @short_company_name)

    @company_short_names = policy_scope(Bi::WorkHoursDayCountDept).select(:orgcode)
      .distinct.where(date: beginning_of_day..end_of_day).collect do |r|
        [Bi::OrgShortName.company_short_names_by_orgcode.fetch(r.orgcode, r.orgcode), r.orgcode]
      end

    @is_non_construction = Report::BaseController::NON_CONSTRUCTION_COMPANYS.include?(@short_company_name)

    data = policy_scope(Bi::WorkHoursDayCountDept).where(date: beginning_of_day..end_of_day)
      .where(orgcode: @selected_company_code)
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'").where('ORG_REPORT_DEPT_ORDER.开始时间 <= ?', end_of_day)
      .where('ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?', end_of_day)

    data = if @view_deptcode_sum
      data
        .select('WORK_HOURS_DAY_COUNT_DEPT.deptcode_sum deptcode, ORG_REPORT_DEPT_ORDER.部门类别, SUM(date_real) date_real, SUM(date_need) date_need, SUM(blue_print_real) blue_print_real, SUM(blue_print_need) blue_print_need, SUM(blue_print_real_unapproved) blue_print_real_unapproved, SUM(construction_real) construction_real, SUM(construction_need) construction_need, SUM(construction_real_unapproved) construction_real_unapproved, SUM(others_real) others_real, SUM(others_need) others_need, SUM(others_real_unapproved) others_real_unapproved')
        .joins('LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = WORK_HOURS_DAY_COUNT_DEPT.deptcode_sum')
        .group('ORG_REPORT_DEPT_ORDER.部门排名, WORK_HOURS_DAY_COUNT_DEPT.deptcode_sum, ORG_REPORT_DEPT_ORDER.部门类别')
        .order(Arel.sql('ORG_REPORT_DEPT_ORDER.部门排名, WORK_HOURS_DAY_COUNT_DEPT.deptcode_sum, ORG_REPORT_DEPT_ORDER.部门类别'))
    else
      data
        .select('WORK_HOURS_DAY_COUNT_DEPT.deptcode, ORG_REPORT_DEPT_ORDER.部门类别, SUM(date_real) date_real, SUM(date_need) date_need, SUM(blue_print_real) blue_print_real, SUM(blue_print_need) blue_print_need, SUM(blue_print_real_unapproved) blue_print_real_unapproved, SUM(construction_real) construction_real, SUM(construction_need) construction_need, SUM(construction_real_unapproved) construction_real_unapproved, SUM(others_real) others_real, SUM(others_need) others_need, SUM(others_real_unapproved) others_real_unapproved')
        .joins('LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = WORK_HOURS_DAY_COUNT_DEPT.deptcode')
        .group('ORG_REPORT_DEPT_ORDER.部门排名, WORK_HOURS_DAY_COUNT_DEPT.deptcode, ORG_REPORT_DEPT_ORDER.部门类别')
        .order(Arel.sql('ORG_REPORT_DEPT_ORDER.部门排名, WORK_HOURS_DAY_COUNT_DEPT.deptcode, ORG_REPORT_DEPT_ORDER.部门类别'))
    end

    @job_company_or_department_codes = data.filter_map do |d|
      if d.date_need.to_f > 0
        # exclude 建筑专项技术咨询所
        if !(%w[00010100801].include?(d.deptcode)) && @short_company_name == '上海天华'
          d.deptcode
        elsif d.部门类别 == '生产' && @short_company_name != '上海天华'
          d.deptcode
        end
      end
    end
    @job_company_or_department_names = @job_company_or_department_codes.collect do |dept_code|
      Bi::PkCodeName.mapping2deptcode.fetch(dept_code, dept_code)
    end

    @blue_print_company_or_department_codes = data.filter_map do |d|
      if d.blue_print_need.to_f > 0
        # exclude 公建一所 施工图综合所 建筑专项技术咨询所
        if !(%w[000101022 000101045 00010100801].include?(d.deptcode)) && @short_company_name == '上海天华'
          d.deptcode
        elsif d.部门类别 == '生产' && @short_company_name != '上海天华'
          d.deptcode
        end
      end
    end
    @blue_print_company_or_department_names = @blue_print_company_or_department_codes.collect do |dept_code|
      Bi::PkCodeName.mapping2deptcode.fetch(dept_code, dept_code)
    end

    @construction_company_or_department_codes = data.filter_map do |d|
      if d.construction_need.to_f > 0
        # exclude 集团创作研究中心 建筑二所（总） 建筑八所 建筑专项技术咨询所 建筑一A所 建筑二A所 建筑二C所 建筑三所 建筑三A所 建筑四所 建筑七所 公建七所 天华建筑创作工作室
        if !(%w[000101194 000101150 000101018 00010100801 000101055 000101143 000101122 000101013 000101125 000101061 000101017 000101075 000101072].include?(d.deptcode)) && @short_company_name == '上海天华'
          d.deptcode
        elsif d.部门类别 == '生产' && @short_company_name != '上海天华'
          d.deptcode
        end
      end
    end
    @construction_company_or_department_names = @construction_company_or_department_codes.collect do |dept_code|
      Bi::PkCodeName.mapping2deptcode.fetch(dept_code, dept_code)
    end

    @non_construction_company_or_department_codes = data.filter_map do |d|
      if d.others_need.to_f > 0
        if d.部门类别 == '生产'
          d.deptcode
        end
      end
    end
    @non_construction_company_or_department_names = @non_construction_company_or_department_codes.collect do |dept_code|
      Bi::PkCodeName.mapping2deptcode.fetch(dept_code, dept_code)
    end

    @day_rate = data.filter_map { |d| ((d.date_real / d.date_need.to_f) * 100).round(0) rescue 0 if @job_company_or_department_codes.include?(d.deptcode) }
    @planning_day_unapproved_rate = data.filter_map { |d| ((d.blue_print_real_unapproved / d.blue_print_need.to_f) * 100).round(0) rescue 0 if @blue_print_company_or_department_codes.include?(d.deptcode) }
    @planning_day_rate = data.filter_map { |d| ((d.blue_print_real / d.blue_print_need.to_f) * 100).round(0) rescue 0 if @blue_print_company_or_department_codes.include?(d.deptcode) }
    @building_day_unapproved_rate = data.filter_map { |d| ((d.construction_real_unapproved / d.construction_need.to_f) * 100).round(0) rescue 0 if @construction_company_or_department_codes.include?(d.deptcode) }
    @building_day_rate = data.filter_map { |d| ((d.construction_real / d.construction_need.to_f) * 100).round(0) rescue 0 if @construction_company_or_department_codes.include?(d.deptcode) }
    @non_construction_day_unapproved_rate = data.filter_map { |d| ((d.others_real_unapproved / d.others_need.to_f) * 100).round(0) rescue 0 if @non_construction_company_or_department_codes.include?(d.deptcode) }
    @non_construction_day_rate = data.filter_map { |d| ((d.others_real / d.others_need.to_f) * 100).round(0) rescue 0 if @non_construction_company_or_department_codes.include?(d.deptcode) }
  end

  def day_rate_drill_down
    @data =
      @data.select(:date, :date_need, :date_real, :fill_rate)
           .where.not(date_need: nil)
    render
  end

  def planning_day_rate_drill_down
    @data =
      @data.select(:date, :blue_print_need, :blue_print_real, :blue_print_rate)
           .where.not(blue_print_need: nil)
    render
  end

  def building_day_rate_drill_down
    @data =
      @data.select(:date, :construction_need, :construction_real, :construction_rate)
           .where.not(construction_need: nil)
    render
  end

  def export
    beginning_of_day = Date.parse(params[:begin_date]).beginning_of_day
    end_of_day = Date.parse(params[:end_date]).end_of_day
    company_code = params[:company_code]
    view_deptcode_sum = params[:view_deptcode_sum] == 'true'

    data = policy_scope(Bi::WorkHoursCountCombine)
      .select('ncworkno, username, profession, SUM(type1) type1, SUM(type2) type2, SUM(type4) type4, SUM(needhours) needhours')
      .where(date: beginning_of_day..end_of_day, orgcode: company_code)
      .order(:ncworkno, :username, :profession)
      .group(:ncworkno, :username, :profession)

    lunch_work_count, lunch_non_work_count = policy_scope(Bi::WorkHoursCountCombine).lunch_count_hash(company_code, beginning_of_day, end_of_day)

    fill_rate_numerator, fill_rate_denominator = policy_scope(Bi::WorkHoursCountCombine).fill_rate_hash(company_code, nil, beginning_of_day, end_of_day, view_deptcode_sum)

    render_csv_header 'subsidiary people workloading'
    csv_res = CSV.generate do |csv|
      csv << ['NC 工号', '姓名', '实填工时', '应填工时', '填报率', '饱和度', '可发放加班餐补次数', '专业']
      data.each do |d|
        values = []
        values << d.ncworkno
        values << d.username
        values << d.type1.to_f + d.type2.to_f + d.type4.to_f
        values << d.needhours
        numerator = fill_rate_numerator[d.ncworkno]
        denominator = fill_rate_denominator[d.ncworkno]
        fr = if denominator.present?
          fill_rate = (numerator.to_f * 100 / denominator).round(1)
          (fill_rate > 100) ? 100 : fill_rate
        else
          'N/A'
        end
        values << fr
        values << ((d.type1.to_f * 100) / d.needhours.to_f).round(1)
        values << lunch_work_count[d.ncworkno].to_i + lunch_non_work_count[d.ncworkno].to_i
        values << d.profession
        csv << values
      end
    end
    send_data "\xEF\xBB\xBF#{csv_res}", filename: 'subsidiary people workloading.csv'
  end

  private

    def set_drill_down_params_and_title
      authorize Bi::WorkHoursDayCountDept
      short_company_code = params[:company_code]
      @company_name = Bi::OrgShortName.company_long_names_by_orgcode.fetch(short_company_code, short_company_code)
      view_deptcode_sum = params[:view_deptcode_sum] == 'true'
      department_code = params[:department_code]
      begin_date = Date.parse(params[:begin_date]).beginning_of_day
      end_date = Date.parse(params[:end_date]).end_of_day

      @drill_down_subtitle = "#{begin_date.to_date} - #{end_date.to_date}"
      data = policy_scope(Bi::WorkHoursDayCountDept).where(date: begin_date..end_date)
        .where(orgcode: short_company_code)
        .order(date: :desc)
      @data = if view_deptcode_sum
        data.where(deptcode_sum: department_code)
      else
        data.where(deptcode: department_code)
      end
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path },
      { text: t('layouts.sidebar.operation.group_daily_workloading'),
        link: report_group_daily_workloading_path },
      { text: t('layouts.sidebar.operation.subsidiary_daily_workloading'),
        link: report_subsidiary_daily_workloading_path }
      ]
    end


    def set_page_layout_data
      @_sidebar_name = 'operation'
    end
end
