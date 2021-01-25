# frozen_string_literal: true

namespace :sync_nc do
  desc 'Sync all'
  task all: %i[user_cost_type user_job_type user_salary_classification]

  desc 'Sync UserCostType with NC HR_FI_COST_CODE'
  task user_cost_type: :environment do
    Nc::HrFiCostCode.where(listcode: 'HRFI01').each do |cc|
      user_cost_type = SplitCost::UserCostType.find_or_create_by(code: cc.code)
      user_cost_type.update(name: cc.name)
    end
  end

  desc 'Sync UserJobType with NC HR_FI_COST_CODE'
  task user_job_type: :environment do
    Nc::HrFiCostCode.where(listcode: 'BD004_0xx').each do |cc|
      user_job_type = SplitCost::UserJobType.find_or_create_by(code: cc.code)
      user_job_type.update(name: cc.name)
    end
  end

  desc 'Sync UserSalaryClassification with NC HR_FI_COST_CODE'
  task user_salary_classification: :environment do
    Nc::HrFiCostCode.where(listcode: 'HRFI02').each do |cc|
      user_salary_classification = SplitCost::UserSalaryClassification.find_or_create_by(code: cc.code)
      user_salary_classification.update(name: cc.name)
    end
  end
end
