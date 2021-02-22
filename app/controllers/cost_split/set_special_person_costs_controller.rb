# frozen_string_literal: true

class CostSplit::SetSpecialPersonCostsController < CostSplit::BaseController
  before_action :set_user_monthly_part_time_special_job_type_rule, except: %i[index create]

  def index
    prepare_meta_tags title: t('.title')
    @ncworkno = params[:ncworkno] || User.first.clerk_code
    @all_month_names = policy_scope(SplitCost::UserMonthlyPartTimeSpecialJobType).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    beginning_of_month = Date.parse(@month_name).beginning_of_month

    @target_user = if @ncworkno.present?
      User.find_by(clerk_code: @ncworkno)
    end

    @mpts_job_types = if @target_user != User.first
      policy_scope(SplitCost::UserMonthlyPartTimeSpecialJobType).where(user: target_user)
    else
      policy_scope(SplitCost::UserMonthlyPartTimeSpecialJobType)
    end.where(month: beginning_of_month)

    @new_mpts = SplitCost::UserMonthlyPartTimeSpecialJobType.new(month: beginning_of_month, user_id: @target_user.id)
  end

  def show
    render :update
  end

  def edit
  end

  def update
    @mpts_job_type.update(user_monthly_part_time_special_job_type_params)
  end

  def create
    SplitCost::UserMonthlyPartTimeSpecialJobType.create(user_monthly_part_time_special_job_type_params)
    redirect_to cost_split_set_special_person_costs_path, notice: t('.create_success')
  end

  def destroy
    @mpts_job_type.destroy
    redirect_to cost_split_set_special_person_costs_path, notice: t('.destroy_success')
  end

  private

    def set_user_monthly_part_time_special_job_type_rule
      @mpts_job_type = SplitCost::UserMonthlyPartTimeSpecialJobType.find(params[:id])
    end

    def user_monthly_part_time_special_job_type_params
      params.fetch(:split_cost_user_monthly_part_time_special_job_type, {})
        .permit(:month, :user_id, :position_user_id, :user_job_type_id)
    end
end
