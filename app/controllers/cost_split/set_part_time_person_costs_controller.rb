# frozen_string_literal: true

class CostSplit::SetPartTimePersonCostsController < CostSplit::BaseController
  before_action :set_monthly_salary_split_rule, except: %i[index]

  def index
    prepare_meta_tags title: t('.title')
    @ncworkno = params[:ncworkno] || current_user.clerk_code
    @begin_date = params[:begin_date]&.strip || Date.today.beginning_of_year
    @end_date = params[:end_date]&.strip || Date.today.end_of_year
  end
end
