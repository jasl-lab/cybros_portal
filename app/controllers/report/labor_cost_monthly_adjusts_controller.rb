# frozen_string_literal: true

class Report::LaborCostMonthlyAdjustsController < Report::BaseController
  include ActionView::Helpers::NumberHelper

  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t('.title')
    authorize SplitCost::UserSplitClassifySalaryPerMonth
    @all_month_names = policy_scope(SplitCost::UserSplitClassifySalaryPerMonth).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    beginning_of_month = Date.parse(@month_name).beginning_of_month

    cspms = SplitCost::UserSplitClassifySalaryPerMonth
      .where.not(adjust_user_id: nil)
      .where(month: beginning_of_month)

    @cspms = cspms
      .select('users.clerk_code, users.chinese_name, departments.name department_name, departments.company_name,
               positions.name position_name, user_cost_types.name user_cost_type_name,
               users.locked_at, user_job_types.name user_job_type_name,
               amount, adjust_users.chinese_name adjust_user_name, adjust_reason, user_split_classify_salary_per_months.id')
      .joins(:user, :position, :user_job_type, :user_cost_type)
      .joins('INNER JOIN `users` adjust_users ON `adjust_users`.`id` = `user_split_classify_salary_per_months`.`adjust_user_id`')
      .joins('LEFT JOIN `departments` ON `departments`.`id` = `positions`.`department_id`')
      .page(params[:page]).per(my_per_page)

    @org_codes = Bi::OrgShortName.org_options
    @dept_codes = Bi::OrgReportDeptOrder.where("组织编号": @org_codes.first[1]).order(:部门排名).select(:"部门", :"编号").collect do |c|
      ["#{c.部门}(#{c.编号})", c.编号]
    end.uniq
    department_id = Department.find_by(dept_code: @dept_codes.first[1])
    @position_codes = Position.where(department_id: department_id).pluck(:name, :id)
    @user_cost_types = SplitCost::UserCostType.all.order(:code)
    @user_cost_type_id = params[:user_cost_type_id]
  end

  def create
    authorize SplitCost::UserSplitClassifySalaryPerMonth
    month_name = params[:month_name]&.strip
    beginning_of_month = Date.parse(month_name).beginning_of_month

    out_position_code = params[:out_position_code]
    out_user_cost_type_id = params[:out_user_cost_type_id]

    in_position_code = params[:in_position_code]
    in_user_cost_type_id = params[:in_user_cost_type_id]

    adjustment_amount = params[:adjustment_amount].to_f
    adjustment_reason = params[:adjustment_reason]

    user = User.find_by(clerk_code: params[:ncworkno])
    if user.blank?
      return redirect_to report_labor_cost_monthly_adjusts_path(month_name: month_name), notice: '用户不能为空'
    end

    out_position = Position.find_by(id: out_position_code)
    if out_position.blank?
      return redirect_to report_labor_cost_monthly_adjusts_path(month_name: month_name), notice: '调出岗位不存在，请检查'
    end
    out_position_user = PositionUser.find_by(position_id: out_position.id, user_id: user.id)
    out_user_job_type_id = if out_position_user.blank?
      PositionUser.find_by(position_id: out_position.id)&.user_job_type_id
    else
      out_position_user.user_job_type_id
    end

    in_position = Position.find_by(id: in_position_code)
    if in_position.blank?
      return redirect_to report_labor_cost_monthly_adjusts_path(month_name: month_name), notice: '调入岗位不存在，请检查'
    end
    in_position_user = PositionUser.find_by(position_id: in_position.id, user_id: user.id)
    in_user_job_type_id = if in_position_user.blank?
      PositionUser.find_by(position_id: in_position.id)&.user_job_type_id
    else
      in_position_user.user_job_type_id
    end

    SplitCost::UserSplitClassifySalaryPerMonth.create(user_id: user.id, adjust_user_id: current_user.id,
      position_id: out_position.id, month: beginning_of_month,
      user_job_type_id: out_user_job_type_id, user_cost_type_id: out_user_cost_type_id,
      amount: -adjustment_amount, adjust_reason: adjustment_reason)
    SplitCost::UserSplitClassifySalaryPerMonth.create(user_id: user.id, adjust_user_id: current_user.id,
      position_id: in_position.id, month: beginning_of_month,
      user_job_type_id: in_user_job_type_id, user_cost_type_id: in_user_cost_type_id,
      amount: adjustment_amount, adjust_reason: adjustment_reason)
    redirect_to report_labor_cost_monthly_adjusts_path(month_name: month_name), notice: '成功创建人力成本调整记录'
  end

  def destroy
    authorize SplitCost::UserSplitClassifySalaryPerMonth
    month_name = params[:month_name]
    uscspm = SplitCost::UserSplitClassifySalaryPerMonth.find_by(id: params[:id])
    if uscspm.present?
      uscspm.destroy
      redirect_to report_labor_cost_monthly_adjusts_path(month_name: month_name), notice: '成功删除人力成本调整记录'
    else
      redirect_to report_labor_cost_monthly_adjusts_path(month_name: month_name), notice: '无此条人力成本调整记录'
    end
  end

  def out_company_code_change
    org_code = params[:out_company_code]
    @dept_codes = Bi::OrgReportDeptOrder.where("组织编号": org_code).order(:部门排名).select(:"部门", :"编号").select(:"部门", :"编号").collect do |c|
      ["#{c.部门}(#{c.编号})", c.编号]
    end.uniq
  end

  def out_department_code_change
    department_code = params[:out_department_code]
    department = Department.find_by(dept_code: department_code)
    @position_codes = Position.where(department_id: department&.id).pluck(:name, :id).uniq
  end

  def in_company_code_change
    org_code = params[:in_company_code]
    @dept_codes = Bi::OrgReportDeptOrder.where("组织编号": org_code).order(:部门排名).select(:"部门", :"编号").select(:"部门", :"编号").collect do |c|
      ["#{c.部门}(#{c.编号})", c.编号]
    end.uniq
  end

  def in_department_code_change
    department_code = params[:in_department_code]
    department = Department.find_by(dept_code: department_code)
    @position_codes = Position.where(department_id: department&.id).pluck(:name, :id).uniq
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'application'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.application.labor_cost_monthly_adjusts'),
        link: report_labor_cost_monthly_adjusts_path }]
    end
end
