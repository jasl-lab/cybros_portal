# frozen_string_literal: true

class CostSplit::SetSpecialPersonCostsController < CostSplit::BaseController
  before_action :set_user_monthly_part_time_special_job_type_rule, except: %i[index]

  def index
    prepare_meta_tags title: t('.title')
    @ncworkno = params[:ncworkno] || User.first.clerk_code
    @all_month_names = policy_scope(SplitCost::UserMonthlyPartTimeSpecialJobType).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    beginning_of_month = Date.parse(@month_name).beginning_of_month

    target_user = if @ncworkno.present?
      User.find_by(clerk_code: @ncworkno)
    end

    @mpts_job_types = if target_user != User.first
      policy_scope(SplitCost::UserMonthlyPartTimeSpecialJobType).where(user: target_user)
    else
      policy_scope(SplitCost::UserMonthlyPartTimeSpecialJobType)
    end.where(month: beginning_of_month)
  end

  def show
    render :update
  end

  def edit
  end

  def update
    @mpts_job_type.update(user_monthly_part_time_special_job_type_params)
  end

  private

    def set_user_monthly_part_time_special_job_type_rule
      @mpts_job_type = SplitCost::UserMonthlyPartTimeSpecialJobType.find(params[:id])
    end

    def user_monthly_part_time_special_job_type_params
      params.fetch(:split_cost_user_monthly_part_time_special_job_type, {})
        .permit(:user_job_type_id)
    end
end
