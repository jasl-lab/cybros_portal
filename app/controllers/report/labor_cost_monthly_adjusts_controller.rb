# frozen_string_literal: true

class Report::LaborCostMonthlyAdjustsController < Report::BaseController
  include ActionView::Helpers::NumberHelper

  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def show
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
               amount, adjust_users.chinese_name adjust_user_name')
      .joins(:user, :position, :user_job_type, :user_cost_type)
      .joins('INNER JOIN `users` adjust_users ON `adjust_users`.`id` = `user_split_classify_salary_per_months`.`adjust_user_id`')
      .joins('LEFT JOIN `departments` ON `departments`.`id` = `positions`.`department_id`')
      .page(params[:page]).per(my_per_page)

    @org_codes = Bi::OrgShortName.org_options
    @dept_codes = Bi::OrgReportDeptOrder.where("组织编号": @org_codes.first[1]).order(:部门排名).pluck(:"部门", :"编号")
    department_id = Department.find_by(dept_code: @dept_codes.first[1])
    @position_codes = Position.where(department_id: department_id).pluck(:name, :id)
    @user_cost_types = SplitCost::UserCostType.all.order(:code)
    @user_cost_type_id = params[:user_cost_type_id]
  end

  def create
  end

  def out_company_code_change
    org_code = params[:out_company_code]
    @dept_codes = Bi::OrgReportDeptOrder.where("组织编号": org_code).order(:部门排名).pluck(:"部门", :"编号")
  end

  def out_department_code_change
    department_code = params[:out_department_code]
    department_id = Department.find_by(dept_code: department_code)
    @position_codes = Position.where(department_id: department_id).pluck(:name, :id)
  end

  def in_company_code_change
    org_code = params[:in_company_code]
    @dept_codes = Bi::OrgReportDeptOrder.where("组织编号": org_code).order(:部门排名).pluck(:"部门", :"编号")
  end

  def in_department_code_change
    department_code = params[:in_department_code]
    department_id = Department.find_by(dept_code: department_code)
    @position_codes = Position.where(department_id: department_id).pluck(:name, :id)
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'application'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.financial_management.header'),
        link: report_financial_management_path }]
    end
end
