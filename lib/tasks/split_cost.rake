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
        split_item_cost_to_companies(split_cost_item, 该资产当月需要摊销金额, cyearperiod_month_start, nil)
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
        split_item_cost_to_companies(split_cost_item, 该资产当月需要摊销金额, cyearperiod_month_start, bill_no)
      else
        puts "Can not find split_cost_item, asset_code: #{asset_code} asset_name: #{asset_name}"
      end
    end
  end

  def split_item_cost_to_companies(split_cost_item, split_amount, cyearperiod_month_start, bill_no)
    unless split_cost_item.group_rate.zero?
      group_rate_base_name = split_cost_item.group_rate_base
      摊销资产分母_company_codes = split_cost_item.split_cost_item_group_rate_companies.collect(&:company_code)
      摊销资产分母 = SplitCost::CostSplitAllocationBase.head_count_at(group_rate_base_name, 摊销资产分母_company_codes, cyearperiod_month_start)
      split_cost_item.split_cost_item_group_rate_companies.each do |grc|
        摊销资产分子_company_code = grc.company_code
        摊销资产分子 = SplitCost::CostSplitAllocationBase.head_count_at(group_rate_base_name, 摊销资产分子_company_code, cyearperiod_month_start)
        split_cost_item_detail = SplitCost::SplitCostItemDetail.find_or_initialize_by(split_cost_item_id: split_cost_item.id, month: cyearperiod_month_start, to_split_company_code: grc.company_code)
        split_cost_item_detail.split_cost_item_category = split_cost_item.split_cost_item_category
        split_cost_item_detail.from_dept_code = split_cost_item.from_dept_code
        split_cost_item_detail.bill_no = bill_no
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
        split_cost_item_detail.from_dept_code = split_cost_item.from_dept_code
        split_cost_item_detail.bill_no = bill_no
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
        split_cost_item_detail.from_dept_code = split_cost_item.from_dept_code
        split_cost_item_detail.bill_no = bill_no
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
      该员工当月需要摊销金额 = 需要摊销的工资 + 水电房租 / 当前计算月份上海天华人数

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
      staff_avg_now = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '创意板块平均总人数', company_code: c.orgcode_sum)
      staff_avg_now.update(start_date: "#{c.pmonth}-01", version: 1,
        head_count: c.staff_now)
      # 创意板块及新业务
      staff_new_now = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '创意板块及新业务', company_code: c.orgcode_sum)
      staff_new_now.update(start_date: "#{c.pmonth}-01", version: 1,
        head_count: c.staff_now)

      # 创意板块上海区域人数
      work_shanghai = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '创意板块上海区域人数', company_code: c.orgcode_sum)
      if SplitCost::CostSplitAllocationBase::SHANGHAI_BASE_COMPANY_CODE.include?(c.orgcode_sum)
        work_shanghai.update(start_date: "#{c.pmonth}-01", version: 1,
          head_count: c.staff_now)
      else
        work_shanghai.update(start_date: "#{c.pmonth}-01", version: 1,
          head_count: c.work_shanghai)
      end

      # 创意板块及新业务（上海区域）
      work_shanghai_new = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '创意板块及新业务（上海区域）', company_code: c.orgcode_sum)
      if SplitCost::CostSplitAllocationBase::SHANGHAI_BASE_NEW_COMPANY_CODE.include?(c.orgcode_sum)
        work_shanghai_new.update(start_date: "#{c.pmonth}-01", version: 1,
          head_count: c.staff_now)
      else
        work_shanghai_new.update(start_date: "#{c.pmonth}-01", version: 1,
          head_count: c.work_shanghai)
      end

      # 施工图人数
      construction_design_electrical = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '施工图人数', company_code: c.orgcode_sum)
      construction_design_electrical.update(start_date: "#{c.pmonth}-01", version: 1,
        head_count: c.profession_construction_design + c.profession_construction + c.profession_electrical)

      # 方案人数
      profession_draw_design = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '方案人数', company_code: c.orgcode_sum)
      profession_draw_design.update(start_date: "#{c.pmonth}-01", version: 1,
        head_count: c.profession_draw_design)

      # 建筑人数
      construction_draw_design = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '建筑人数', company_code: c.orgcode_sum)
      construction_draw_design.update(start_date: "#{c.pmonth}-01", version: 1,
        head_count: c.profession_draw_design + c.profession_construction_design)

      # 结构人数
      profession_construction = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '结构人数', company_code: c.orgcode_sum)
      profession_construction.update(start_date: "#{c.pmonth}-01", version: 1,
        head_count: c.profession_construction)

      # 机电人数
      profession_electrical = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '机电人数', company_code: c.orgcode_sum)
      profession_electrical.update(start_date: "#{c.pmonth}-01", version: 1,
        head_count: c.profession_electrical)
    end
    Hrdw::ComMonthReport.where(pmonth: "2019-12").each do |c|
      # 上年平均人数
      staff_avg_now = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '上年平均人数', company_code: c.orgcode_sum)
      staff_avg_now.update(start_date: "#{c.pmonth}-01", version: 1,
        head_count: c.staff_now)
    end
  end
end
