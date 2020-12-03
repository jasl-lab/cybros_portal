# frozen_string_literal: true

class CostSplit::UserSplitCostSettingsController < CostSplit::BaseController
  before_action :set_user_and_split_cost_setting, except: %i[create new]

  def new
  end

  def create
    @scs = SplitCost::UserSplitCostSetting.new(scs_params)
    @user = @scs.user
    @scs.start_date ||= Date.today
    @scs.version = @user.user_split_cost_settings.count
    @scs.save
  end

  def edit
  end

  def update
    @scs.update(scs_params)
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
      @scs = SplitCost::UserSplitCostSetting.find(params[:id])
      @user = @scs.user
    end
end
