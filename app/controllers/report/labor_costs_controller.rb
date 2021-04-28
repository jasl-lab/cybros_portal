# frozen_string_literal: true

class Report::LaborCostsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
    authorize SplitCost::UserSplitClassifySalaryPerMonth
    @all_month_names = policy_scope(SplitCost::UserSplitClassifySalaryPerMonth).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    beginning_of_month = Date.parse(@month_name).beginning_of_month
    @user_cost_types = SplitCost::UserCostType.all.order(:code)
    @user_cost_type_id = params[:user_cost_type_id]

    cspms = SplitCost::UserSplitClassifySalaryPerMonth.where(month: beginning_of_month)
    @cspms = if @user_cost_type_id.present?
      cspms.where(user_cost_type_id: @user_cost_type_id)
    else
      cspms
    end.select('users.clerk_code, users.chinese_name, departments.name department_name, departments.company_name, user_cost_types.name user_cost_type_name, sum(amount) total')
      .joins(:user, { position: :department }, :user_cost_type)
      .group(:"users.clerk_code", :"users.chinese_name", :"departments.name", :"departments.company_name", :"user_cost_types.name")
      .order(:"users.clerk_code", :"users.chinese_name", :"departments.name", :"departments.company_name", :"user_cost_types.name")
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
