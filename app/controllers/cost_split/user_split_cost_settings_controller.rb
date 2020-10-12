# frozen_string_literal: true

class CostSplit::UserSplitCostSettingsController < CostSplit::BaseController
  def create
    scs = UserSplitCostSetting.new(scs_params)
    @user = scs.user
    scs.start_date ||= Date.today
    scs.version = @user.user_split_cost_settings.count
    scs.save!
  end

  def update
    @scs = UserSplitCostSetting.find (params[:id])
    @user = @scs.user
  end

  private

    def scs_params
      params.fetch(:user_split_cost_setting, {})
        .permit(:user_id, :org_code, :dept_code, :position_title,
          :group_rate, :shanghai_area, :shanghai_hq, :version)
    end
end
