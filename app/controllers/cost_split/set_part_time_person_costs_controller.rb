# frozen_string_literal: true

class CostSplit::SetPartTimePersonCostsController < CostSplit::BaseController
  before_action :set_page_layout_data, if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t('.title')
    @clerk_code = params[:clerk_code]
    @chinese_name = params[:chinese_name]

    @all_month_names = policy_scope(SplitCost::UserMonthlyPartTimeSplitRate).all_month_names
    @month_name = params[:month_name]&.strip || @all_month_names.first
    @beginning_of_month = Date.parse(@month_name).beginning_of_month

    @company_short_names = policy_scope(SplitCost::UserMonthlyPartTimeSplitRate).available_company_name_org_codes(@beginning_of_month)
    @main_company_code = params[:main_company_code].presence
    @parttime_company_code = params[:parttime_company_code].presence

    users_ids = User.includes(user_monthly_part_time_split_rates: :position)
      .where(user_monthly_part_time_split_rates: { month: @beginning_of_month })
      .pluck(:id).uniq

    @mpts_rates = if @parttime_company_code.present? && @main_company_code.present?
      policy_scope(SplitCost::UserMonthlyPartTimeSplitRate)
        .where(position: { departments: { company_code: [@main_company_code, @parttime_company_code] } })
    elsif @main_company_code.present?
      policy_scope(SplitCost::UserMonthlyPartTimeSplitRate)
        .where(position: { departments: { company_code: @main_company_code } })
        .where(main_position: true)
    elsif @parttime_company_code.present?
      policy_scope(SplitCost::UserMonthlyPartTimeSplitRate)
        .where(position: { departments: { company_code: @parttime_company_code } })
        .where(main_position: false)
    else
      policy_scope(SplitCost::UserMonthlyPartTimeSplitRate)
    end.where(month: @beginning_of_month)

    @users = if current_user.part_time_split_access_codes.present?
      cu = User.joins(user_monthly_part_time_split_rates: { position: :department })
      current_user.part_time_split_access_codes.each_with_index do |ac, index|
        if index == 0
          cu = if ac.dept_category.present?
            cu.where(user_monthly_part_time_split_rates: { main_position: true })
              .where(user_monthly_part_time_split_rates: { positions: { departments: { company_code: ac.org_code, dept_category: ac.dept_category } } })
          else
            cu.where(user_monthly_part_time_split_rates: { positions: { departments: { company_code: ac.org_code } } })
          end
        else
          cu = cu.or(if ac.dept_category.present?
                 cu.where(user_monthly_part_time_split_rates: { main_position: true })
                   .where(user_monthly_part_time_split_rates: { positions: { departments: { company_code: ac.org_code, dept_category: ac.dept_category } } })
               else
                 cu.where(user_monthly_part_time_split_rates: { positions: { departments: { company_code: ac.org_code } } })
               end)
        end
      end
      cu.where(id: users_ids).distinct # because users table joins.
    else
      User.where(id: users_ids)
    end.where(id: @mpts_rates.collect(&:user_id))

    @users = @users.where(clerk_code: @clerk_code) if @clerk_code.present?
    @users = @users.where('chinese_name LIKE ?', "%#{@chinese_name}%") if @chinese_name.present?

    @users = @users.page(params[:page]).per(my_per_page)

    @user_salary_classifications = SplitCost::UserSalaryClassification.all.order(:code)
  end

  def part_time_people
    @users = User.joins(:position_users)
      .where(position_users: { main_position: false })
      .where('chinese_name LIKE ?', "%#{params[:q]}%").distinct.limit(7)
  end

  def edit
    @month_name = params[:month_name]&.strip
    @beginning_of_month = Date.parse(@month_name).beginning_of_month
    @user = User.includes(:user_monthly_part_time_split_rates).find params[:id]
    @user_monthly_part_time_split_rates = @user.user_monthly_part_time_split_rates.where(month: @beginning_of_month)
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

  protected

    def set_page_layout_data
      @_sidebar_name = 'split_settings'
    end
end
