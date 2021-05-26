# frozen_string_literal: true

namespace :split_cost do
  desc 'Generate split cost item details'
  task :generate_split_cost_item_details, [:cyearperiod] => [:environment] do |task, args|
    cyearperiod = args[:cyearperiod]
    cyearperiod_year = cyearperiod[0..3]
    cyearperiod_month = cyearperiod[4..5]
    cyearperiod_month_start = Date.parse("#{cyearperiod_year}-#{cyearperiod_month}-01")

    Nc::CardLog.where('depamount > 0').where(yp: cyearperiod).each do |card_log|
      next if card_log.depamount.blank?

      该资产当月需要摊销金额 = card_log.depamount
      asset_name = card_log.asset_name
      asset_code = card_log.asset_code
      split_cost_item = SplitCost::SplitCostItem.where(split_cost_item_no: asset_code)
        .where('start_date <= ?', cyearperiod_month_start).order(version: :desc).first
      if split_cost_item.present?
        puts "Processing CardLog asset_code: #{asset_code} asset_name: #{asset_name}"
        split_item_cost_to_companies(split_cost_item, 该资产当月需要摊销金额, cyearperiod_month_start, nil, split_cost_item.from_dept_code)
      else
        puts "Can not find split_cost_item, asset_code: #{asset_code} asset_name: #{asset_name}"
      end
    end
    Nc::YsfsLine.where('moneycr > 0').where(year: cyearperiod_year, month: cyearperiod_month).each do |ysfs_line|
      next if ysfs_line.moneycr.blank?

      该资产当月需要摊销金额 = ysfs_line.moneycr
      asset_name = ysfs_line.ysname
      asset_code = ysfs_line.yscode
      bill_no = ysfs_line.billno
      split_cost_item = SplitCost::SplitCostItem.where(split_cost_item_no: asset_code)
        .where('start_date <= ?', cyearperiod_month_start).order(version: :desc).first
      if split_cost_item.present?
        puts "Processing YsfsLine asset_code: #{asset_code} asset_name: #{asset_name}"
        split_item_cost_to_companies(split_cost_item, 该资产当月需要摊销金额, cyearperiod_month_start, bill_no, ysfs_line.deptcode)
      else
        puts "Can not find split_cost_item, asset_code: #{asset_code} asset_name: #{asset_name}"
      end
    end
  end

  def split_item_cost_to_companies(split_cost_item, split_amount, cyearperiod_month_start, bill_no, from_dept_code)
    unless split_cost_item.group_rate.zero?
      group_rate_base_name = split_cost_item.group_rate_base
      摊销资产分母_company_codes = split_cost_item.split_cost_item_group_rate_companies.collect(&:company_code)
      摊销资产分母 = SplitCost::CostSplitAllocationBase.head_count_at(group_rate_base_name, 摊销资产分母_company_codes, cyearperiod_month_start)
      split_cost_item.split_cost_item_group_rate_companies.each do |grc|
        摊销资产分子_company_code = grc.company_code
        摊销资产分子 = SplitCost::CostSplitAllocationBase.head_count_at(group_rate_base_name, 摊销资产分子_company_code, cyearperiod_month_start)
        split_cost_item_detail = SplitCost::SplitCostItemDetail.find_or_initialize_by(split_cost_item_id: split_cost_item.id, month: cyearperiod_month_start, to_split_company_code: grc.company_code)
        split_cost_item_detail.split_cost_item_category = split_cost_item.split_cost_item_category
        split_cost_item_detail.from_dept_code = from_dept_code
        split_cost_item_detail.bill_no = bill_no
        split_cost_item_detail.group_cost_numerator = 摊销资产分子
        split_cost_item_detail.group_cost = split_amount * (split_cost_item.group_rate / 100.0) * (摊销资产分子 / 摊销资产分母.to_f)
        split_cost_item_detail.save
      end
    end
    unless split_cost_item.shanghai_area.zero?
      shanghai_area_base_name = split_cost_item.shanghai_area_base
      摊销资产分母_company_codes = split_cost_item.split_cost_item_shanghai_area_rate_companies.collect(&:company_code)
      摊销资产分母 = SplitCost::CostSplitAllocationBase.head_count_at(shanghai_area_base_name, 摊销资产分母_company_codes, cyearperiod_month_start)
      split_cost_item.split_cost_item_shanghai_area_rate_companies.each do |sarc|
        摊销资产分子_company_code = sarc.company_code
        摊销资产分子 = SplitCost::CostSplitAllocationBase.head_count_at(shanghai_area_base_name, 摊销资产分子_company_code, cyearperiod_month_start)
        split_cost_item_detail = SplitCost::SplitCostItemDetail.find_or_initialize_by(split_cost_item_id: split_cost_item.id, month: cyearperiod_month_start, to_split_company_code: sarc.company_code)
        split_cost_item_detail.split_cost_item_category = split_cost_item.split_cost_item_category
        split_cost_item_detail.from_dept_code = from_dept_code
        split_cost_item_detail.bill_no = bill_no
        split_cost_item_detail.shanghai_area_cost_numerator = 摊销资产分子
        split_cost_item_detail.shanghai_area_cost = split_amount * (split_cost_item.shanghai_area / 100.0) * (摊销资产分子 / 摊销资产分母.to_f)
        split_cost_item_detail.save
      end
    end
    unless split_cost_item.shanghai_hq.zero?
      shanghai_hq_base_name = split_cost_item.shanghai_hq_base
      摊销资产分母_company_codes = split_cost_item.split_cost_item_shanghai_hq_rate_companies.collect(&:company_code)
      摊销资产分母 = SplitCost::CostSplitAllocationBase.head_count_at(shanghai_hq_base_name, 摊销资产分母_company_codes, cyearperiod_month_start)
      split_cost_item.split_cost_item_shanghai_hq_rate_companies.each do |shrc|
        摊销资产分子_company_code = shrc.company_code
        摊销资产分子 = SplitCost::CostSplitAllocationBase.head_count_at(shanghai_hq_base_name, 摊销资产分子_company_code, cyearperiod_month_start)
        split_cost_item_detail = SplitCost::SplitCostItemDetail.find_or_initialize_by(split_cost_item_id: split_cost_item.id, month: cyearperiod_month_start, to_split_company_code: shrc.company_code)
        split_cost_item_detail.split_cost_item_category = split_cost_item.split_cost_item_category
        split_cost_item_detail.from_dept_code = from_dept_code
        split_cost_item_detail.bill_no = bill_no
        split_cost_item_detail.shanghai_hq_cost_numerator = 摊销资产分子
        split_cost_item_detail.shanghai_hq_cost = split_amount * (split_cost_item.shanghai_hq / 100.0) * (摊销资产分子 / 摊销资产分母.to_f)
        split_cost_item_detail.save
      end
    end
  end

  desc 'Generate user split cost details'
  task :generate_user_split_cost_details, [:cyearperiod] => [:environment] do |task, args|
    cyearperiod = args[:cyearperiod]
    cyearperiod_month_start = Date.parse("#{cyearperiod[0..3]}-#{cyearperiod[4..5]}-01")
    水电房租 = Nc::Balance.countc_at_month(cyearperiod)
    # 上海天华
    当前计算月份上海天华人数 = SplitCost::CostSplitAllocationBase.head_count_at('创意板块平均总人数', '000101', cyearperiod_month_start)
    raise '当前月份没有人数数据' unless 当前计算月份上海天华人数.present?
    Nc::WaTa.where(cyearperiod: cyearperiod).each do |wata|
      需要摊销的工资 = wata.sum_gz + wata.sb * wata.sbpercent + wata.gjj * wata.gjjpercent
      该员工当月需要摊销金额 = 需要摊销的工资 + 水电房租 / 当前计算月份上海天华人数.to_f

      v_wata_dept_code = wata.deptcode
      clerk_code = wata.code
      user = User.find_by(clerk_code: clerk_code)
      if user.present?
        user_split_cost_setting = user.user_split_cost_settings.where('start_date <= ?', cyearperiod_month_start).order(version: :desc).first
        if user_split_cost_setting.present?
          split_user_cost_to_companies(user_split_cost_setting, 该员工当月需要摊销金额, v_wata_dept_code, cyearperiod_month_start)
        else
          puts "Can not find user_split_cost_setting, clert_code: #{clerk_code}, name: #{wata.name}"
        end
      else
        puts "Can not find user, clert_code: #{clerk_code}, name: #{wata.name}"
      end
    end
  end

  def split_user_cost_to_companies(user_split_cost_setting, split_amount, v_wata_dept_code, cyearperiod_month_start)
    unless user_split_cost_setting.group_rate.zero?
      group_rate_base_name = user_split_cost_setting.group_rate_base
      摊销人数分母_company_codes = user_split_cost_setting.user_split_cost_group_rate_companies.collect(&:company_code)
      摊销人数分母 = SplitCost::CostSplitAllocationBase.head_count_at(group_rate_base_name, 摊销人数分母_company_codes, cyearperiod_month_start)
      user_split_cost_setting.user_split_cost_group_rate_companies.each do |grc|
        摊销人数分子_company_code = grc.company_code
        摊销人数分子 = SplitCost::CostSplitAllocationBase.head_count_at(group_rate_base_name, 摊销人数分子_company_code, cyearperiod_month_start)
        user_split_cost_detail = SplitCost::UserSplitCostDetail.find_or_initialize_by(v_wata_dept_code: v_wata_dept_code, user_id: user_split_cost_setting.user.id, month: cyearperiod_month_start, to_split_company_code: grc.company_code)
        user_split_cost_detail.group_cost_numerator = 摊销人数分子
        user_split_cost_detail.group_cost = split_amount * (user_split_cost_setting.group_rate / 100.0) * (摊销人数分子 / 摊销人数分母.to_f)
        user_split_cost_detail.save
      end
    end
    unless user_split_cost_setting.shanghai_area.zero?
      shanghai_area_base_name = user_split_cost_setting.shanghai_area_base
      摊销人数分母_company_codes = user_split_cost_setting.user_split_cost_shanghai_area_rate_companies.collect(&:company_code)
      摊销人数分母 = SplitCost::CostSplitAllocationBase.head_count_at(shanghai_area_base_name, 摊销人数分母_company_codes, cyearperiod_month_start)
      user_split_cost_setting.user_split_cost_shanghai_area_rate_companies.each do |sarc|
        摊销人数分子_company_code = sarc.company_code
        摊销人数分子 = SplitCost::CostSplitAllocationBase.head_count_at(shanghai_area_base_name, 摊销人数分子_company_code, cyearperiod_month_start)
        user_split_cost_detail = SplitCost::UserSplitCostDetail.find_or_initialize_by(v_wata_dept_code: v_wata_dept_code, user_id: user_split_cost_setting.user.id, month: cyearperiod_month_start, to_split_company_code: sarc.company_code)
        user_split_cost_detail.shanghai_area_cost_numerator = 摊销人数分子
        user_split_cost_detail.shanghai_area_cost = split_amount * (user_split_cost_setting.shanghai_area / 100.0) * (摊销人数分子 / 摊销人数分母.to_f)
        user_split_cost_detail.save
      end
    end
    unless user_split_cost_setting.shanghai_hq.zero?
      shanghai_hq_base_name = user_split_cost_setting.shanghai_hq_base
      摊销人数分母_company_codes = user_split_cost_setting.user_split_cost_shanghai_hq_rate_companies.collect(&:company_code)
      摊销人数分母 = SplitCost::CostSplitAllocationBase.head_count_at(shanghai_hq_base_name, 摊销人数分母_company_codes, cyearperiod_month_start)
      user_split_cost_setting.user_split_cost_shanghai_hq_rate_companies.each do |shrc|
        摊销人数分子_company_code = shrc.company_code
        摊销人数分子 = SplitCost::CostSplitAllocationBase.head_count_at(shanghai_hq_base_name, 摊销人数分子_company_code, cyearperiod_month_start)
        user_split_cost_detail = SplitCost::UserSplitCostDetail.find_or_initialize_by(v_wata_dept_code: v_wata_dept_code, user_id: user_split_cost_setting.user.id, month: cyearperiod_month_start, to_split_company_code: shrc.company_code)
        user_split_cost_detail.shanghai_hq_cost_numerator = 摊销人数分子
        user_split_cost_detail.shanghai_hq_cost = split_amount * (user_split_cost_setting.shanghai_hq / 100.0) * (摊销人数分子 / 摊销人数分母.to_f)
        user_split_cost_detail.save
      end
    end
  end

  desc 'Import HRDW COM_MONTH_REPORT into cybros'
  task :hrdw_com_month_report_import, [:cyearperiod] => [:environment] do |task, args|
    cyearperiod = args[:cyearperiod]
    Hrdw::ComMonthReport.where(pmonth: "#{cyearperiod[0..3]}-#{cyearperiod[4..5]}").each do |c|
      # 创意板块平均总人数
      staff_avg_now = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '创意板块平均总人数', company_code: c.orgcode_sum, pmonth: c.pmonth)
      staff_avg_now.update(head_count: c.staff_now)
      # 创意板块及新业务
      staff_new_now = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '创意板块及新业务', company_code: c.orgcode_sum, pmonth: c.pmonth)
      staff_new_now.update(head_count: c.staff_now)

      # 创意板块上海区域人数
      work_shanghai = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '创意板块上海区域人数', company_code: c.orgcode_sum, pmonth: c.pmonth)
      if SplitCost::CostSplitAllocationBase::SHANGHAI_BASE_COMPANY_CODE.include?(c.orgcode_sum)
        work_shanghai.update(head_count: c.staff_now)
      else
        work_shanghai.update(head_count: c.work_shanghai)
      end

      # 创意板块及新业务（上海区域）
      work_shanghai_new = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '创意板块及新业务（上海区域）', company_code: c.orgcode_sum, pmonth: c.pmonth)
      if SplitCost::CostSplitAllocationBase::SHANGHAI_BASE_NEW_COMPANY_CODE.include?(c.orgcode_sum)
        work_shanghai_new.update(head_count: c.staff_now)
      else
        work_shanghai_new.update(head_count: c.work_shanghai)
      end

      # 施工图人数
      construction_design_electrical = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '施工图人数', company_code: c.orgcode_sum, pmonth: c.pmonth)
      construction_design_electrical.update(head_count: c.profession_construction_design.to_i + c.profession_construction.to_i + c.profession_electrical.to_i)

      # 方案人数
      profession_draw_design = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '方案人数', company_code: c.orgcode_sum, pmonth: c.pmonth)
      profession_draw_design.update(head_count: c.profession_draw_design)

      # 建筑人数
      construction_draw_design = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '建筑人数', company_code: c.orgcode_sum, pmonth: c.pmonth)
      construction_draw_design.update(head_count: c.profession_draw_design.to_i + c.profession_construction_design.to_i)

      # 结构人数
      profession_construction = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '结构人数', company_code: c.orgcode_sum, pmonth: c.pmonth)
      profession_construction.update(head_count: c.profession_construction)

      # 机电人数
      profession_electrical = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '机电人数', company_code: c.orgcode_sum, pmonth: c.pmonth)
      profession_electrical.update(head_count: c.profession_electrical)
    end
    Hrdw::ComMonthReport.where(pmonth: '2019-12').each do |c|
      # 上年平均人数
      last_year_staff_avg_now = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '上年平均人数', company_code: c.orgcode_sum, pmonth: "#{cyearperiod[0..3]}-#{cyearperiod[4..5]}")
      last_year_staff_avg_now.update(head_count: c.staff_now)
    end
  end

  # Steps to generate labor_cost
  # 1. run split_cost:nc_v_classify_salary_import
  # 2. run split_cost:generate_user_monthly_part_time_splits
  # 3. run split_cost:copy_user_monthly_part_time_split_rates
  # 4. run split_cost:copy_special_person_costs
  # 5. run split_cost:user_split_classify_salary_per_months
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
      user_id = User.find_by(clerk_code: cs.clerkcode)&.id
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

      upsert_user_split_classify_salary(user_id, cyearperiod_month_start, 基本工资_classification_id,
        belong_company_name, belong_department_name, job_position, cs.基本工资, user_job_type_id)
      upsert_user_split_classify_salary(user_id, cyearperiod_month_start, 预发设计费_classification_id,
        belong_company_name, belong_department_name, job_position, cs.预发设计费, user_job_type_id)
      upsert_user_split_classify_salary(user_id, cyearperiod_month_start, 岗位补贴_classification_id,
        belong_company_name, belong_department_name, job_position, cs.公司补贴, user_job_type_id)
      upsert_user_split_classify_salary(user_id, cyearperiod_month_start, 资质补贴_classification_id,
        belong_company_name, belong_department_name, job_position, cs.资质补贴, user_job_type_id)
      upsert_user_split_classify_salary(user_id, cyearperiod_month_start, 预发待扣_classification_id,
        belong_company_name, belong_department_name, job_position, cs.预发待扣, user_job_type_id)
      upsert_user_split_classify_salary(user_id, cyearperiod_month_start, 其他_classification_id,
        belong_company_name, belong_department_name, job_position, cs.其他, user_job_type_id)
    end
  end

  def upsert_user_split_classify_salary(user_id, month, user_salary_classification_id, belong_company_name, belong_department_name, job_position, amount, user_job_type_id)
    classify_salary = SplitCost::UserSplitClassifySalary.find_or_initialize_by(user_id: user_id, month: month,
                               user_salary_classification_id: user_salary_classification_id)
    classify_salary.update(belong_company_name: belong_company_name, belong_department_name: belong_department_name,
        job_position: job_position, amount: amount, user_job_type_id: user_job_type_id)
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
      next if user.position_users.count.zero?

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
        query_job_type_id, final_cost_type_id = get_user_cost_type_id(cyearperiod_month_start, user.id, position_user.id,
          scs.user_job_type_id, scs.user_salary_classification_id)
        SplitCost::UserSplitClassifySalaryPerMonth.create(month: cyearperiod_month_start,
          user_id: user.id, position_id: position_user.position_id,
          user_job_type_id: query_job_type_id, main_position: position_user.main_position,
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
end
