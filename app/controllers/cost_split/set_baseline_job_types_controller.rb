# frozen_string_literal: true

class CostSplit::SetBaselineJobTypesController < CostSplit::BaseController
  def index
    prepare_meta_tags title: t('.title')
    @all_month_names = policy_scope(SplitCost::MonthlySalarySplitRule).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    beginning_of_month = Date.parse(@month_name).beginning_of_month

    @user_salary_classifications = SplitCost::UserSalaryClassification.all.order(:code)
    @user_job_types = SplitCost::UserJobType.all.order(:code)
    @monthly_salary_split_rules = SplitCost::MonthlySalarySplitRule.where(month: beginning_of_month)
  end
end
