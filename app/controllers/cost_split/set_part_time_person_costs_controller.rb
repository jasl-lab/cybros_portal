# frozen_string_literal: true

class CostSplit::SetPartTimePersonCostsController < CostSplit::BaseController
  def index
    prepare_meta_tags title: t('.title')
    @ncworkno = params[:ncworkno] || User.first.clerk_code

    @all_month_names = policy_scope(SplitCost::UserMonthlyPartTimeSplitRate).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    beginning_of_month = Date.parse(@month_name).beginning_of_month

    @users = User.joins(:position_users).includes(:user_monthly_part_time_split_rates)
      .where(position_users: { main_position: false }).distinct

    @users = if @ncworkno != '015454'
      @users.where(clerk_code: @ncworkno)
    else
      @users
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

  def edit
    @month_name = params[:month_name]&.strip
    beginning_of_month = Date.parse(@month_name).beginning_of_month
    @user = User.includes(:user_monthly_part_time_split_rates).find params[:id]
    @user_monthly_part_time_split_rates = @user.user_monthly_part_time_split_rates.where(month: beginning_of_month)
    @user_salary_classifications = SplitCost::UserSalaryClassification.all.order(:code)
  end

  def update
    month_name = params[:month_name]&.strip
    beginning_of_month = Date.parse(month_name).beginning_of_month
    user = User.includes(:user_monthly_part_time_split_rates).find params[:id]
    mpts_rates = user.user_monthly_part_time_split_rates.where(month: beginning_of_month)
    @mpts_ids = params[:ids]
    @mpts_values = params[:values]
    @mpts_ids.each_with_index do |m_id, index|
      mpts_rate = mpts_rates.find_by!(id: m_id)
      mpts_rate.update(salary_classification_split_rate: @mpts_values[index])
    end
  end
end
