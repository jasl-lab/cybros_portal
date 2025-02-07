# frozen_string_literal: true

class Report::SubsidiaryDesignCashFlowsController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def show
    authorize Bi::DeptMoneyFlow
    prepare_meta_tags title: t('.title')
    @all_month_names = Bi::DeptMoneyFlow.all_month_names
    @end_of_month = Date.parse(@all_month_names.first).end_of_month
    beginning_of_year = @end_of_month.beginning_of_year
    @depts_options = params[:depts]
    @view_deptcode_sum = params[:view_deptcode_sum] == 'true'
    @found_time = params[:found_time].presence
    @biz_type = params[:biz_type].presence
    @selected_short_name = params[:company_name]&.strip || current_user.user_company_short_name

    available_company_orgcodes = policy_scope(Bi::DeptMoneyFlow)
        .where(checkdate: beginning_of_year..@end_of_month)
        .joins('LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = OCDM.V_TH_DEPTMONEYFLOW.comp')
        .where('ORG_ORDER.org_order is not null')
        .where("ORG_ORDER.org_type = '创意板块'")
        .order('ORG_ORDER.org_order ASC')
        .pluck(:comp).uniq
    @available_short_company_names = available_company_orgcodes.collect { |c| Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c) }

    selected_orgcode = Bi::OrgShortName.org_code_by_short_name.fetch(@selected_short_name, @selected_short_name)

    data_last_available_date = policy_scope(Bi::DeptMoneyFlow).last_available_date(@end_of_month)
    data = policy_scope(Bi::DeptMoneyFlow)
      .where(checkdate: beginning_of_year..@end_of_month)
      .where(comp: selected_orgcode)

    data_org = data
      .select('OCDM.V_TH_DEPTMONEYFLOW.checkdate, SUM(IFNULL(OCDM.V_TH_DEPTMONEYFLOW.endmoney,0)) endmoney, SUM(IFNULL(OCDM.V_TH_DEPTMONEYFLOW.nexthrpaymoney,0)) nexthrpaymoney')
      .group('OCDM.V_TH_DEPTMONEYFLOW.checkdate')
      .order(Arel.sql('OCDM.V_TH_DEPTMONEYFLOW.checkdate'))
    @org_checkdate = data_org.collect { |d| d.checkdate.month }
    @org_endmoney = data_org.collect(&:endmoney)
    org_nexthrpaymoney = data_org.collect(&:nexthrpaymoney)
    @org_rate = @org_endmoney.map.with_index { |x, i| (x / org_nexthrpaymoney[i].to_f).round(2) }

    data = data
      .where("ORG_REPORT_DEPT_ORDER.是否显示 = '1'")
      .where('ORG_REPORT_DEPT_ORDER.开始时间 <= ?', data_last_available_date)
      .select('OCDM.V_TH_DEPTMONEYFLOW.dept deptcode, OCDM.V_TH_DEPTMONEYFLOW.checkdate, IFNULL(OCDM.V_TH_DEPTMONEYFLOW.endmoney,0) endmoney')
      .where('ORG_REPORT_DEPT_ORDER.结束时间 IS NULL OR ORG_REPORT_DEPT_ORDER.结束时间 >= ?', data_last_available_date)
      .joins('LEFT JOIN ORG_REPORT_DEPT_ORDER on ORG_REPORT_DEPT_ORDER.编号 = OCDM.V_TH_DEPTMONEYFLOW.dept')
      .order(Arel.sql('ORG_REPORT_DEPT_ORDER.部门排名, OCDM.V_TH_DEPTMONEYFLOW.dept, OCDM.V_TH_DEPTMONEYFLOW.checkdate'))

    data = if @view_deptcode_sum
      data.where('ORG_REPORT_DEPT_ORDER.上级部门编号 IS NULL')
    else
      data
    end

    only_have_data_depts = data.collect(&:deptcode)
    only_have_data_depts = case @found_time
                           when '三年以上'
                             Bi::CwCashflowFillHeader.where('createdate <= ?', 3.years.ago)
                               .where(deptcode: only_have_data_depts).pluck(:deptcode)
                           when '三年以内'
                             Bi::CwCashflowFillHeader.where('createdate > ?', 3.years.ago)
                               .where(deptcode: only_have_data_depts).pluck(:deptcode)
                           else
                             only_have_data_depts
    end

    only_have_data_depts = if @biz_type.present?
      Bi::CwCashflowFillHeader.where(deptbusitype: @biz_type)
        .where(deptcode: only_have_data_depts).pluck(:deptcode)
    else
      only_have_data_depts
    end

    department_short_names = only_have_data_depts.collect { |d| Bi::OrgReportDeptOrder.department_names(data_last_available_date).fetch(d, Bi::PkCodeName.mapping2deptcode.fetch(d, d)) }
    @depts_options = only_have_data_depts if @depts_options.blank?
    @department_options = department_short_names.zip(only_have_data_depts)

    data_dept = data.where(dept: @depts_options)
    @data_deptcodes = data_dept.collect(&:deptcode).uniq
    @dept_endmoney = []
    @data_deptcodes.collect do |dept_code|
      @dept_endmoney << data_dept.filter_map { |d| d.endmoney if d.deptcode == dept_code }
    end
    @dept_short_names = @data_deptcodes.collect { |d| Bi::OrgReportDeptOrder.department_names(data_last_available_date).fetch(d, Bi::PkCodeName.mapping2deptcode.fetch(d, d)) }
  end

  protected

    def set_page_layout_data
      @_sidebar_name = 'operation'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.operation.header'),
        link: report_operation_path }]
    end
end
