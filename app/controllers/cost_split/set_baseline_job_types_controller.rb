# frozen_string_literal: true

class CostSplit::SetBaselineJobTypesController < CostSplit::BaseController
  def index
    prepare_meta_tags title: t('.title')
    @user_salary_classifications = SplitCost::UserSalaryClassification.all.order(:code)
    @user_job_types = SplitCost::UserJobType.all.order(:code)
  end
end
