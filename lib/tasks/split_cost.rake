# frozen_string_literal: true

namespace :split_cost do
  desc 'Generate user split cost details'
  task :generate_user_split_cost_details, [:cyearperiod] => [:environment] do |task, args|
    cyearperiod = args[:cyearperiod]
    cyearperiod_month_start = Date.parse("#{cyearperiod[0..3]}-#{cyearperiod[4..5]}-01")
    水电房租 = Nc::Balance.countc_at_month(cyearperiod)
    # 上海天华
    当前计算月份上海天华人数 = SplitCost::CostSplitAllocationBase.head_count_at('创意板块平均总人数', '000101', cyearperiod_month_start)
    raise '当前月份没有人数数据' unless 当前计算月份上海天华人数.present?
    Nc::WaTa.all.each do |wata|
      需要摊销的工资 = wata.sum_gz + wata.sb * wata.sbpercent + wata.gjj * wata.gjjpercent
      该员工当月需要摊销金额 = 需要摊销的工资 + 水电房租 / 当前计算月份上海天华人数

      v_wata_dept_code = wata.deptcode
      clerk_code = wata.code
      user = User.find_by(clerk_code: clerk_code)
      if user.present?
        user_split_cost_setting = user.user_split_cost_settings.where("start_date <= ?", cyearperiod_month_start).order(version: :desc).first
        if user_split_cost_setting.present?
          split_cost_to_companies(user_split_cost_setting, 该员工当月需要摊销金额, v_wata_dept_code, cyearperiod_month_start)
        else
          puts "Can not find user_split_cost_setting, clert_code: #{clerk_code}, name: #{wata.name}"
        end
      else
        puts "Can not find user, clert_code: #{clerk_code}, name: #{wata.name}"
      end
    end
  end

  def split_cost_to_companies(user_split_cost_setting, split_amount, v_wata_dept_code, cyearperiod_month_start)
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
  task hrdw_com_month_report_import: :environment do
    Hrdw::ComMonthReport.all.each do |c|
      # 创意板块平均总人数
      staff_now = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '创意板块平均总人数', company_code: c.orgcode_sum)
      staff_now.update(start_date: "#{c.pmonth}-01", version: 1,
        head_count: c.staff_now)

      # 创意板块上海区域人数
      work_shanghai = SplitCost::CostSplitAllocationBase.find_or_create_by(base_name: '创意板块上海区域人数', company_code: c.orgcode_sum)
      work_shanghai.update(start_date: "#{c.pmonth}-01", version: 1,
        head_count: c.work_shanghai)

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
  end
end
