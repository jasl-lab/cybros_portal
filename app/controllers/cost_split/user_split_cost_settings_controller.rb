# frozen_string_literal: true

class CostSplit::UserSplitCostSettingsController < CostSplit::BaseController
  before_action :set_user_and_split_cost_setting, only: %i[edit update]

  def new
    user = User.find_by(id: params[:user_id])
    @user_split_cost_setting = SplitCost::UserSplitCostSetting.new(
      user_id: user.id,
      org_code: user.user_company_orgcode,
      dept_code: user.user_department_code,
      position_title: user.position_title
    )
  end

  def create
    @user_split_cost_setting = SplitCost::UserSplitCostSetting.new(scs_params)
    @user = @user_split_cost_setting.user
    @user_split_cost_setting.start_date ||= Date.today
    @user_split_cost_setting.version = @user.user_split_cost_settings.count
    @user_split_cost_setting.save
  end

  def edit
  end

  def update
    @user_split_cost_setting.update(scs_params)
  end

  private

    def scs_params
      params.fetch(:split_cost_user_split_cost_setting, {})
        .permit(:user_id, :org_code, :dept_code, :position_title,
          :group_rate, :shanghai_area, :shanghai_hq,
          :group_rate_base, :shanghai_area_base, :shanghai_hq_base,
          :version,
          user_split_cost_group_rate_companies_codes: [],
          user_split_cost_shanghai_area_rate_companies_codes: [],
          user_split_cost_shanghai_hq_rate_companies_codes: [])
    end

    def set_user_and_split_cost_setting
      @user_split_cost_setting = SplitCost::UserSplitCostSetting.find(params[:id])
      @user = @user_split_cost_setting.user
    end
end
