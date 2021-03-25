# frozen_string_literal: true

class CostSplit::SetSpecialPersonCostsController < CostSplit::BaseController
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_user_monthly_part_time_special_job_type_rule, except: %i[index create]

  def index
    prepare_meta_tags title: t('.title')
    noone_user = User.find 11229
    @ncworkno = params[:ncworkno] || noone_user.clerk_code
    @all_month_names = policy_scope(SplitCost::UserMonthlyPartTimeSpecialJobType).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first || Time.zone.now.to_s(:month_and_year)
    beginning_of_month = Date.parse(@month_name).beginning_of_month

    @target_user = if @ncworkno.present?
      User.find_by(clerk_code: @ncworkno)
    else
      noone_user
    end

    @mpts_job_types = if @target_user != noone_user
      policy_scope(SplitCost::UserMonthlyPartTimeSpecialJobType).where(user: @target_user)
    else
      policy_scope(SplitCost::UserMonthlyPartTimeSpecialJobType)
    end.where(month: beginning_of_month)

    @default_user_job_type_id = @target_user.position_users.pluck(:user_job_type_id).first
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
    mpts_job_type = SplitCost::UserMonthlyPartTimeSpecialJobType.create(user_monthly_part_time_special_job_type_params)
    if mpts_job_type.errors.present?
      redirect_to cost_split_set_special_person_costs_path, notice: t('.create_need_user')
    else
      redirect_to cost_split_set_special_person_costs_path, notice: t('.create_success')
    end
  end

  def destroy
    @mpts_job_type.destroy
    redirect_to cost_split_set_special_person_costs_path, notice: t('.destroy_success')
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'split_settings'
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
