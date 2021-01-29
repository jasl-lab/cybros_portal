# frozen_string_literal: true

class CostSplit::SetPartTimePersonCostsController < CostSplit::BaseController
  before_action :set_monthly_salary_split_rule, except: %i[index]

  def index
    prepare_meta_tags title: t('.title')
  end
end
