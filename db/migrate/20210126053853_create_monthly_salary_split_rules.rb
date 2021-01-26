class CreateMonthlySalarySplitRules < ActiveRecord::Migration[6.1]
  def change
    create_table :monthly_salary_split_rules do |t|
      t.references :user_job_type, null: false, foreign_key: true
      t.references :user_salary_classification, null: false, foreign_key: true, index: { name: 'idx_monthly_salary_split_rules_on_salary_classification_id' }
      t.references :user_cost_type, null: false, foreign_key: true
      t.date :month

      t.timestamps
    end
    基本工资_classification_id = SplitCost::UserSalaryClassification.find_by!(code: '10').id
    预发设计费_classification_id = SplitCost::UserSalaryClassification.find_by!(code: '20').id
    岗位补贴_classification_id = SplitCost::UserSalaryClassification.find_by!(code: '30').id
    资质补贴_classification_id = SplitCost::UserSalaryClassification.find_by!(code: '40').id
    预发待扣_classification_id = SplitCost::UserSalaryClassification.find_by!(code: '50').id
    其他_classification_id = SplitCost::UserSalaryClassification.find_by!(code: '60').id

    非一线人员_job_type_id = SplitCost::UserJobType.find_by!(code: 'xz01').id
    所级设计管理人员_job_type_id = SplitCost::UserJobType.find_by!(code: 'xz02').id
    所级经营管理人员_job_type_id = SplitCost::UserJobType.find_by!(code: 'xz03').id
    其他设计人员_job_type_id = SplitCost::UserJobType.find_by!(code: 'xz04').id

    部门承担人力成本_cost_type_id = SplitCost::UserCostType.find_by!(code: '10').id
    设计预发待扣_cost_type_id = SplitCost::UserCostType.find_by!(code: '20').id
    公司管理费用_cost_type_id = SplitCost::UserCostType.find_by!(code: '30').id
    管理预发待扣_cost_type_id = SplitCost::UserCostType.find_by!(code: '60').id

    start_date = Date.new(2020, 12, 1)

    # 基本工资
    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 基本工资_classification_id,
      user_job_type_id: 非一线人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 基本工资_classification_id,
      user_job_type_id: 所级设计管理人员_job_type_id,
      user_cost_type_id: 部门承担人力成本_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 基本工资_classification_id,
      user_job_type_id: 所级经营管理人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 基本工资_classification_id,
      user_job_type_id: 其他设计人员_job_type_id,
      user_cost_type_id: 部门承担人力成本_cost_type_id)

    # 预发设计费
    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 预发设计费_classification_id,
      user_job_type_id: 非一线人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 预发设计费_classification_id,
      user_job_type_id: 所级设计管理人员_job_type_id,
      user_cost_type_id: 部门承担人力成本_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 预发设计费_classification_id,
      user_job_type_id: 所级经营管理人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 预发设计费_classification_id,
      user_job_type_id: 其他设计人员_job_type_id,
      user_cost_type_id: 部门承担人力成本_cost_type_id)

    # 岗位补贴
    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 岗位补贴_classification_id,
      user_job_type_id: 非一线人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 岗位补贴_classification_id,
      user_job_type_id: 所级设计管理人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 岗位补贴_classification_id,
      user_job_type_id: 所级经营管理人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 岗位补贴_classification_id,
      user_job_type_id: 其他设计人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    # 资质补贴
    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 资质补贴_classification_id,
      user_job_type_id: 非一线人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 资质补贴_classification_id,
      user_job_type_id: 所级设计管理人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 资质补贴_classification_id,
      user_job_type_id: 所级经营管理人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 资质补贴_classification_id,
      user_job_type_id: 其他设计人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    # 预发待扣
    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 预发待扣_classification_id,
      user_job_type_id: 非一线人员_job_type_id,
      user_cost_type_id: 管理预发待扣_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 预发待扣_classification_id,
      user_job_type_id: 所级设计管理人员_job_type_id,
      user_cost_type_id: 管理预发待扣_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 预发待扣_classification_id,
      user_job_type_id: 所级经营管理人员_job_type_id,
      user_cost_type_id: 管理预发待扣_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 预发待扣_classification_id,
      user_job_type_id: 其他设计人员_job_type_id,
      user_cost_type_id: 设计预发待扣_cost_type_id)

    # 其他
    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 其他_classification_id,
      user_job_type_id: 非一线人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 其他_classification_id,
      user_job_type_id: 所级设计管理人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 其他_classification_id,
      user_job_type_id: 所级经营管理人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)

    SplitCost::MonthlySalarySplitRule.create(month: start_date,
      user_salary_classification_id: 其他_classification_id,
      user_job_type_id: 其他设计人员_job_type_id,
      user_cost_type_id: 公司管理费用_cost_type_id)
  end
end
