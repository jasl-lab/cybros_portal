# frozen_string_literal: true

namespace :human_split do
  # Steps to generate labor_cost
  # 1. run nc_v_classify_salary_import
  # 2. run copy_user_monthly_part_time_split_rates
  # 3. run copy_special_person_costs
  # 4. run user_split_classify_salary_per_months
  desc 'Import NC V_CLASSIFY_SALARY into cybros'
  task :nc_v_classify_salary_import, [:cyearperiod] => [:environment] do |task, args|
    cyearperiod = args[:cyearperiod]
    cyearperiod_year = cyearperiod[0..3]
    cyearperiod_month = cyearperiod[4..5]
    cyearperiod_month_start = Date.parse("#{cyearperiod_year}-#{cyearperiod_month}-01")

    基本工资_classification_id = SplitCost::UserSalaryClassification.find_by!(code: '10').id
    预发设计费_classification_id = SplitCost::UserSalaryClassification.find_by!(code: '20').id
    岗位补贴_classification_id = SplitCost::UserSalaryClassification.find_by!(code: '30').id
    资质补贴_classification_id = SplitCost::UserSalaryClassification.find_by!(code: '40').id
    预发待扣_classification_id = SplitCost::UserSalaryClassification.find_by!(code: '50').id
    其他_classification_id = SplitCost::UserSalaryClassification.find_by!(code: '60').id

    Nc::ClassifySalary.where(ym: cyearperiod).each do |cs|
      next if cs.classify_post.blank?
      user_id = User.joins(:department_users).find_by(clerk_code: cs.clerkcode)&.id
      if user_id.blank?
        puts "clerkcode #{cs.clerkcode} not existing"
        next
      else
        puts "#{cs.clerkcode}: #{cs.classify_post} #{cs.基本工资}  #{cs.预发设计费}  #{cs.公司补贴}  #{cs.资质补贴}  #{cs.预发待扣}  #{cs.其他}"
      end
      belong_company_name = cs.orgname
      belong_department_name = nil
      job_position = cs.postname
      user_job_type_id = SplitCost::UserJobType.find_by!(code: cs.classify_post).id
      nc_pk_post = cs.nc_pk_post

      upsert_user_split_classify_salary(user_id, cyearperiod_month_start, 基本工资_classification_id,
        belong_company_name, belong_department_name, job_position, cs.基本工资, user_job_type_id, nc_pk_post)
      upsert_user_split_classify_salary(user_id, cyearperiod_month_start, 预发设计费_classification_id,
        belong_company_name, belong_department_name, job_position, cs.预发设计费, user_job_type_id, nc_pk_post)
      upsert_user_split_classify_salary(user_id, cyearperiod_month_start, 岗位补贴_classification_id,
        belong_company_name, belong_department_name, job_position, cs.公司补贴, user_job_type_id, nc_pk_post)
      upsert_user_split_classify_salary(user_id, cyearperiod_month_start, 资质补贴_classification_id,
        belong_company_name, belong_department_name, job_position, cs.资质补贴, user_job_type_id, nc_pk_post)
      upsert_user_split_classify_salary(user_id, cyearperiod_month_start, 预发待扣_classification_id,
        belong_company_name, belong_department_name, job_position, cs.预发待扣, user_job_type_id, nc_pk_post)
      upsert_user_split_classify_salary(user_id, cyearperiod_month_start, 其他_classification_id,
        belong_company_name, belong_department_name, job_position, cs.其他, user_job_type_id, nc_pk_post)
    end
  end

  def upsert_user_split_classify_salary(user_id, month, user_salary_classification_id,
                                        belong_company_name, belong_department_name, job_position,
                                        amount, user_job_type_id, nc_pk_post)
    classify_salary = SplitCost::UserSplitClassifySalary.find_or_initialize_by(user_id: user_id, month: month,
                               user_salary_classification_id: user_salary_classification_id)
    classify_salary.update(belong_company_name: belong_company_name, belong_department_name: belong_department_name,
        job_position: job_position, amount: amount, user_job_type_id: user_job_type_id, nc_pk_post: nc_pk_post)
  end

  desc 'Copy user monthly part time splits rate from previous month'
  task :copy_user_monthly_part_time_split_rates, [:cyearperiod, :from_yearperiod] => [:environment] do |task, args|
    cyearperiod = args[:cyearperiod]
    cyearperiod_year = cyearperiod[0..3]
    cyearperiod_month = cyearperiod[4..5]
    cyearperiod_month_start = Date.parse("#{cyearperiod_year}-#{cyearperiod_month}-01")

    from_yearperiod = args[:from_yearperiod]
    from_yearperiod_year = from_yearperiod[0..3]
    from_yearperiod_month = from_yearperiod[4..5]
    from_yearperiod_month_start = Date.parse("#{from_yearperiod_year}-#{from_yearperiod_month}-01")

    puts "Copy part time split rates from #{from_yearperiod_month_start} to #{cyearperiod_month_start}"
    user_ids = PositionUser.where(main_position: false).pluck(:user_id).uniq
    User.where(id: user_ids).where(locked_at: nil).each do |user|
      new_position_ids = user.position_users.pluck(:position_id).uniq.sort
      previous_position_ids = SplitCost::UserMonthlyPartTimeSplitRate.where(user_id: user.id, month: from_yearperiod_month_start).pluck(:position_id).uniq.sort

      user.position_users.each do |pu|
        SplitCost::UserSalaryClassification.all.each do |sc|
          prev_ptsr = SplitCost::UserMonthlyPartTimeSplitRate.find_by(user_id: user.id, month: from_yearperiod_month_start, position_id: pu.position.id, user_salary_classification_id: sc.id)
          ptsr = SplitCost::UserMonthlyPartTimeSplitRate.find_or_initialize_by(user_id: user.id, month: cyearperiod_month_start, position_id: pu.position.id, user_salary_classification_id: sc.id)
          ptsr.update(main_position: pu.main_position, salary_classification_split_rate: prev_ptsr&.salary_classification_split_rate || (pu.main_position ? 100 : 0))
        end
      end

      if new_position_ids != previous_position_ids
        puts "User position changed: #{user.id}:#{user.chinese_name}"
      end
    end
  end

  desc 'Copy special person costs from previous month'
  task :copy_special_person_costs, [:cyearperiod, :from_yearperiod] => [:environment] do |task, args|
    cyearperiod = args[:cyearperiod]
    cyearperiod_year = cyearperiod[0..3]
    cyearperiod_month = cyearperiod[4..5]
    cyearperiod_month_start = Date.parse("#{cyearperiod_year}-#{cyearperiod_month}-01")

    from_yearperiod = args[:from_yearperiod]
    from_yearperiod_year = from_yearperiod[0..3]
    from_yearperiod_month = from_yearperiod[4..5]
    from_yearperiod_month_start = Date.parse("#{from_yearperiod_year}-#{from_yearperiod_month}-01")

    puts "Copy special person costs from #{from_yearperiod_month_start} to #{cyearperiod_month_start}"

    SplitCost::UserMonthlyPartTimeSpecialJobType.where(month: from_yearperiod_month_start).each do |previous_ptsjt|
      ptsjt = SplitCost::UserMonthlyPartTimeSpecialJobType.find_or_initialize_by(user_id: previous_ptsjt.user_id, month: cyearperiod_month_start, position_user_id: previous_ptsjt.position_user_id)
      ptsjt.update(user_job_type_id: previous_ptsjt.user_job_type_id)
    end
  end

  desc 'Generate user split classify salary per months from user_split_classify_salaries'
  task :user_split_classify_salary_per_months, [:cyearperiod] => [:environment] do |task, args|
    cyearperiod = args[:cyearperiod]
    cyearperiod_year = cyearperiod[0..3]
    cyearperiod_month = cyearperiod[4..5]
    cyearperiod_month_start = Date.parse("#{cyearperiod_year}-#{cyearperiod_month}-01")
    SplitCost::UserSplitClassifySalary.where(month: cyearperiod_month_start).find_each do |scs|
      next if scs.amount.zero?

      user = scs.user
      # next unless user.id == 178

      user_mpts = user.user_monthly_part_time_split_rates.where(month: cyearperiod_month_start,
        user_salary_classification_id: scs.user_salary_classification_id)
      if user_mpts.present?
        user_mpts.each do |mpts|
          next if mpts.salary_classification_split_rate.nil?
          next if mpts.salary_classification_split_rate.zero?

          query_job_type_id, final_cost_type_id = get_user_cost_type_id(cyearperiod_month_start, user.id, mpts.position_id,
            (mpts.user_job_type_id || scs.user_job_type_id), mpts.user_salary_classification_id)
          per_month_amount = scs.amount * (mpts.salary_classification_split_rate / 100.0)
          # puts "#{user.id} mpts.position_id #{mpts.position_id} scs.amount #{scs.amount} final_cost_type_id: #{final_cost_type_id} mpts.salary_classification_split_rate #{mpts.salary_classification_split_rate} per_month_amount #{per_month_amount}"
          SplitCost::UserSplitClassifySalaryPerMonth.create(month: cyearperiod_month_start,
            user_id: user.id, position_id: mpts.position_id,
            user_job_type_id: query_job_type_id, main_position: mpts.main_position,
            user_cost_type_id: final_cost_type_id, amount: per_month_amount)
        end
      else
        position_user = user.position_users.find_by(main_position: true) || user.position_users.last
        position_user_id = position_user&.id
        position_id = position_user&.position_id || Position.find_by(nc_pk_post: scs.nc_pk_post)&.id
        main_position = position_user&.main_position || true
        query_job_type_id, final_cost_type_id = get_user_cost_type_id(cyearperiod_month_start, user.id, position_user_id,
          scs.user_job_type_id, scs.user_salary_classification_id)
        SplitCost::UserSplitClassifySalaryPerMonth.create(month: cyearperiod_month_start,
          user_id: user.id, position_id: position_id,
          user_job_type_id: query_job_type_id, main_position: main_position,
          user_cost_type_id: final_cost_type_id, amount: scs.amount)
      end
    end
  end

  def get_user_cost_type_id(month, user_id, position_user_id, input_job_type_id, input_salary_classification_id)
    special_job_type_id = SplitCost::UserMonthlyPartTimeSpecialJobType.find_by(month: month,
      user_id: user_id, position_user_id: position_user_id)&.user_job_type_id
    query_job_type_id = special_job_type_id || input_job_type_id
    final_cost_type_id = SplitCost::MonthlySalarySplitRule.find_by(month: month,
      user_job_type_id: query_job_type_id, user_salary_classification_id: input_salary_classification_id)&.user_cost_type_id
    return query_job_type_id, final_cost_type_id
  end

  desc 'Generate part time split settings'
  task :generate_user_monthly_part_time_splits, [:cyearperiod] => [:environment] do |task, args|
    cyearperiod = args[:cyearperiod]
    cyearperiod_year = cyearperiod[0..3]
    cyearperiod_month = cyearperiod[4..5]
    cyearperiod_month_start = Date.parse("#{cyearperiod_year}-#{cyearperiod_month}-01")

    user_ids = PositionUser.where(main_position: false).pluck(:user_id).uniq
    User.where(id: user_ids).where(locked_at: nil).each do |user|
      user.position_users.each do |pu|
        SplitCost::UserSalaryClassification.all.each do |sc|
          ptsr = SplitCost::UserMonthlyPartTimeSplitRate.find_or_initialize_by(user_id: user.id, month: cyearperiod_month_start,
            position_id: pu.position.id, user_salary_classification_id: sc.id)
          ptsr.update(main_position: pu.main_position, user_job_type_id: pu.user_job_type_id, salary_classification_split_rate: pu.main_position ? 100 : 0)
        end
      end
    end
  end
end
