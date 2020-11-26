# frozen_string_literal: true

namespace :split_cost do
  desc 'Generate user split cost details'
  task :generate_user_split_cost_details, [:cyearperiod] => [:environment] do |task, args|
    cyearperiod = args[:cyearperiod]
    水电房租 = Nc::Balance.countc_at_month(cyearperiod)
    当前计算月份上海天华人数 = 1409
    Nc::WaTa.where(cyearperiod: cyearperiod, deptname: '天华集团-流程与信息化部').each do |wata|
      需要摊销的工资 = wata.sum_gz + wata.sb * wata.sbpercent + wata.gjj * wata.gjjpercent
      该员工当月需要摊销金额 = 需要摊销的工资 + 水电房租 / 当前计算月份上海天华人数
      v_wata_dept_code = wata.deptcode
      clerk_code = wata.code
      user = User.find_by(clerk_code: clerk_code)
      if user.present?
        user.user_split_cost_settings.each do |settings|

        end
      else
        "Can not find user, clert_code: #{clerk_code}, name: #{wata.name}"
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
