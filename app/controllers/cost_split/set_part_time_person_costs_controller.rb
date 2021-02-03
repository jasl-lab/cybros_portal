# frozen_string_literal: true

class CostSplit::SetPartTimePersonCostsController < CostSplit::BaseController
  before_action :set_monthly_salary_split_rule, except: %i[index part_time_people]

  def index
    prepare_meta_tags title: t('.title')
    @ncworkno = params[:ncworkno] || User.first.clerk_code
    
    @all_month_names = policy_scope(SplitCost::UserMonthlyPartTimeSplitRate).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    beginning_of_month = Date.parse(@month_name).beginning_of_month

    @users = User.joins(:position_users)
      .where(position_users: { main_position: false }).distinct

    if @ncworkno.present?
      @users.where(clerk_code: @ncworkno)
    end

    @mpts_rates = if @users.first != User.first
      policy_scope(SplitCost::UserMonthlyPartTimeSplitRate).where(user: @users.first)
    else
      policy_scope(SplitCost::UserMonthlyPartTimeSplitRate)
    end.where(month: beginning_of_month)

    @users = @users.page(params[:page]).per(params[:per_page])
    @user_salary_classifications = SplitCost::UserSalaryClassification.all.order(:code)
  end

  def part_time_people
    @users = User.joins(:position_users)
      .where(position_users: { main_position: false })
      .where('chinese_name LIKE ?', "%#{params[:q]}%").distinct.limit(7)
  end
end
