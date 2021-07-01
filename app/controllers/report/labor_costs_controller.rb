# frozen_string_literal: true

class Report::LaborCostsController < Report::BaseController
  include ActionView::Helpers::NumberHelper

  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[show], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
    authorize SplitCost::UserSplitClassifySalaryPerMonth
    @company_name = params[:company_name]&.strip
    @department_name = params[:department]&.strip
    @clerk_code = params[:clerk_code]&.strip
    @chinese_name = params[:chinese_name]&.strip

    @all_month_names = policy_scope(SplitCost::UserSplitClassifySalaryPerMonth).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    beginning_of_month = Date.parse(@month_name).beginning_of_month
    @user_cost_types = SplitCost::UserCostType.all.order(:code)
    @user_cost_type_id = params[:user_cost_type_id]

    cspms = policy_scope(SplitCost::UserSplitClassifySalaryPerMonth).where(month: beginning_of_month)

    cspms = if @company_name.present?
      cspms.where('departments.company_name LIKE ?', "%#{@company_name}%")
    else
      cspms
    end

    cspms = if @department_name.present?
      cspms.where('departments.name LIKE ?', "%#{@department_name}%")
    else
      cspms
    end

    cspms = if @clerk_code.present?
      cspms.where('users.clerk_code LIKE ?', "%#{@clerk_code}%")
    else
      cspms
    end

    cspms = if @chinese_name.present?
      cspms.where('users.chinese_name LIKE ?', "%#{@chinese_name}%")
    else
      cspms
    end

    cspms = if @user_cost_type_id.present?
      cspms.where(user_cost_type_id: @user_cost_type_id)
    else
      cspms
    end.select('users.clerk_code, users.chinese_name, departments.name department_name, departments.company_name,
      positions.name position_name, user_cost_types.name user_cost_type_name, users.locked_at, user_job_types.name user_job_type_name,
      sum(amount) total')
      .joins(:user, :position, :user_job_type, :user_cost_type)
      .joins('LEFT JOIN `departments` ON `departments`.`id` = `positions`.`department_id`')
      .group(:"users.clerk_code", :"users.chinese_name", :"departments.name", :"departments.company_name", :"positions.name", :"user_cost_types.name", :"users.locked_at", :"user_job_types.name")
      .order(:"users.clerk_code", :"users.chinese_name", :"departments.name", :"departments.company_name", :"positions.name", :"user_cost_types.name", :"users.locked_at", :"user_job_types.name")

    respond_to do |format|
      format.html do
        @cspms = cspms.page(params[:page]).per(my_per_page)
      end
      format.csv do
        render_csv_header "Labor cost #{@month_name}"
        csv_res = CSV.generate do |csv|
          csv << %w(工号 姓名 所属公司 所属部门 岗位 成本类别 成本性质 查询年月 金额 是否在职)
          cspms.each do |d|
            values = []
            values << d.clerk_code
            values << d.chinese_name
            values << d.company_name
            values << d.department_name
            values << d.position_name
            values << d.user_cost_type_name
            values << d.user_job_type_name
            values << @month_name
            values << number_with_precision(d.total, precision: 0)
            values << (d.locked_at.present? ? '已离职' : '')
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF#{csv_res}", filename: "Labor cost #{@month_name}.csv"
      end
    end
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'application'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.application.labor_costs'),
        link: report_labor_cost_path }]
    end
end
