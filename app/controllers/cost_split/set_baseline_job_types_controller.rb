# frozen_string_literal: true

class CostSplit::SetBaselineJobTypesController < CostSplit::BaseController
  def index
    prepare_meta_tags title: t('.title')
    @all_month_names = policy_scope(SplitCost::MonthlySalarySplitRule).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    beginning_of_month = Date.parse(@month_name).beginning_of_month
    commit_type = params[:commit]

    case commit_type
    when I18n.t('cost_split.set_baseline_job_types.index.generate_prev_month')
      prev_month = beginning_of_month.prev_month
      if SplitCost::MonthlySalarySplitRule.where(month: prev_month).blank?
        SplitCost::MonthlySalarySplitRule.where(month: beginning_of_month).each do |rule|
          SplitCost::MonthlySalarySplitRule.create(month: prev_month,
            user_job_type_id: rule.user_job_type.id,
            user_salary_classification_id: rule.user_salary_classification.id,
            user_cost_type_id: rule.user_cost_type.id)
        end
        redirect_to cost_split_set_baseline_job_types_path(month_name: prev_month.to_s(:month_and_year)), notice: t('.prev_month_generated')
      else
        redirect_to cost_split_set_baseline_job_types_path(month_name: prev_month.to_s(:month_and_year)), alert: t('.prev_month_exist')
      end
    when I18n.t('cost_split.set_baseline_job_types.index.generate_next_month')
      next_month = beginning_of_month.next_month
      if SplitCost::MonthlySalarySplitRule.where(month: prev_month).blank?
        SplitCost::MonthlySalarySplitRule.where(month: beginning_of_month).each do |rule|
          SplitCost::MonthlySalarySplitRule.create(month: next_month,
            user_job_type_id: rule.user_job_type.id,
            user_salary_classification_id: rule.user_salary_classification.id,
            user_cost_type_id: rule.user_cost_type.id)
        end
        redirect_to cost_split_set_baseline_job_types_path(month_name: next_month.to_s(:month_and_year)), notice: t('.next_month_generated')
      else
        redirect_to cost_split_set_baseline_job_types_path(month_name: next_month.to_s(:month_and_year)), alert: t('.next_month_exist')
      end
    else
      @user_salary_classifications = SplitCost::UserSalaryClassification.all.order(:code)
      @user_job_types = SplitCost::UserJobType.all.order(:code)
      @monthly_salary_split_rules = SplitCost::MonthlySalarySplitRule.where(month: beginning_of_month)
    end
  end
end
