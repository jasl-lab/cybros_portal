# frozen_string_literal: true

class CostSplit::SetPartTimePersonCostsController < CostSplit::BaseController
  before_action :set_monthly_salary_split_rule, except: %i[index part_time_people]

  def index
    prepare_meta_tags title: t('.title')
    @ncworkno = params[:ncworkno] || current_user.clerk_code
    
    @all_month_names = policy_scope(SplitCost::UserMonthlyPartTimeSplitRate).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    beginning_of_month = Date.parse(@month_name).beginning_of_month
  end

  def part_time_people
    @users = User.joins(:position_users)
      .where(position_users: { main_position: false})
      .where('chinese_name LIKE ?', "%#{params[:q]}%").limit(7)
  end
end
