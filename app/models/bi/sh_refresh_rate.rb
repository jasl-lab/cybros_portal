# frozen_string_literal: true

module Bi
  class ShRefreshRate < BiLocalTimeRecord
    self.table_name = 'SH_REFRESH_RATE'

    def self.all_month_names(org_code)
      Bi::ShRefreshRate.where(orgcode: org_code).order(date: :desc).pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end

    def self.available_company_names(target_date)
      orgcodes = where(date: target_date).where("SH_REFRESH_RATE.orgcode IS NOT NULL")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = SH_REFRESH_RATE.orgcode")
        .where('ORG_ORDER.org_order is not null')
        .where("ORG_ORDER.org_type = '创意板块'")
        .order("ORG_ORDER.org_order DESC")
        .pluck(:orgcode).uniq
        .collect { |c| [Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c), c] }
    end

    def self.person_count_by_department(target_date)
      deps = where(date: target_date).where("SH_REFRESH_RATE.orgcode IS NOT NULL")
        .select('deptcode, count(work_no) work_no')
        .group(:deptcode).order(deptcode: :asc)
      @_person_count_by_department = deps.reduce({}) do |h, s|
        h[s.deptcode] = s.work_no
        h
      end
    end

    def self.person_by_department_in_sh(target_date, orgcode)
      lad = where(date: target_date).where("是否显示 = '1'")
        .joins("LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = SH_REFRESH_RATE.deptcode and ORG_REPORT_DEPT_ORDER.开始时间 <= '#{target_date.to_date}' and (ORG_REPORT_DEPT_ORDER.结束时间 >= '#{target_date.to_date}' or ORG_REPORT_DEPT_ORDER.结束时间 is null)")
        .order("ORG_REPORT_DEPT_ORDER.部门排名, SH_REFRESH_RATE.deptcode")
      lad = lad.where(orgcode: orgcode)
      h = {}
      department_code_in_order = lad.collect(&:deptcode).uniq
      department_code_in_order.each do |deptcode|
        h[deptcode] = lad.find_all { |rr| rr.deptcode == deptcode }
      end
      h
    end
  end
end
