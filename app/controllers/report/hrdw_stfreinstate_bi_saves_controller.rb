# frozen_string_literal: true

class Report::HrdwStfreinstateBiSavesController < Report::BaseController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def show
    prepare_meta_tags title: t('.title')
    @archive_month = Time.now.day > 3 ? Time.now : Time.now - 1.month
    @stfreinstatebimonth_exist = Hrdw::StfreinstateBiMonth.where(pyear: @archive_month.year, pmonth: @archive_month.month).exists?
    @stfturnoverbimonth_exist = Hrdw::StfturnoverBiMonth.where(pyear: @archive_month.year, pmonth: @archive_month.month).exists?
  end

  def stfreinstate_archive
    @stfreinstatebimonth_exist = Hrdw::StfreinstateBiMonth.where(pyear: params[:year], pmonth: params[:month]).exists?
    if @stfreinstatebimonth_exist
      Hrdw::StfreinstateBiMonth.where(pyear: params[:year], pmonth: params[:month]).delete_all
    end
    Hrdw::StfreinstateBiMonth.connection.execute("
      INSERT INTO HRDW_STFREINSTATE_BI_MONTH(name, clerkcode, begindate, enddate, endflag, lastflag, orgcode_sum, orgname_sum, orgcode, orgname, deptcode_sum, deptname_sum, deptcode, deptname, glbdef1, postname, zjname, trnstypename, pocname, trnsevent, gxname, ischange, comment, profession, stname, pyear, pmonth)
      SELECT name, clerkcode, begindate, enddate, endflag, lastflag, orgcode_sum, orgname_sum, orgcode, orgname, deptcode_sum, deptname_sum, deptcode, deptname, glbdef1, postname, zjname, trnstypename, pocname, trnsevent, gxname, ischange, comment, profession, stname, #{params[:year].to_i}, #{params[:month].to_i}
      FROM HRDW_STFREINSTATE_BI")
    redirect_to report_hrdw_stfreinstate_bi_save_path, notice: 'HRDW_STFREINSTATE_BI_MONTH 归档完成'
  end

  def stfturnover_archive
    @stfturnoverbimonth_exist = Hrdw::StfturnoverBiMonth.where(pyear: params[:year], pmonth: params[:month]).exists?
    if @stfturnoverbimonth_exist
      Hrdw::StfturnoverBiMonth.where(pyear: params[:year], pmonth: params[:month]).delete_all
    end
    Hrdw::StfturnoverBiMonth.connection.execute("
      INSERT INTO HRDW_STFTURNOVER_BI_MONTH(name, clerkcode, effectivedate, employeetype, trnstypename, orgcode_sum_old, orgname_sum_old, orgcode_old, orgname_old, deptcode_sum_old, deptname_sum_old, deptcode_old, deptname_old, postname_old, zjname_old, orgcode_sum_new, orgname_sum_new, orgcode_new, orgname_new, deptcode_sum_new, deptname_sum_new, deptcode_new, deptname_new, postname_new, zjname_new, pyear, pmonth)
      SELECT name, clerkcode, effectivedate, employeetype, trnstypename, orgcode_sum_old, orgname_sum_old, orgcode_old, orgname_old, deptcode_sum_old, deptname_sum_old, deptcode_old, deptname_old, postname_old, zjname_old, orgcode_sum_new, orgname_sum_new, orgcode_new, orgname_new, deptcode_sum_new, deptname_sum_new, deptcode_new, deptname_new, postname_new, zjname_new, #{params[:year].to_i}, #{params[:month].to_i}
      FROM HRDW_STFTURNOVER_BI")
    redirect_to report_hrdw_stfreinstate_bi_save_path, notice: 'HRDW_STFTURNOVER_BI_MONTH 归档完成'
  end


  protected

    def set_page_layout_data
      @_sidebar_name = 'human_resource'
    end

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.human_resource.header'),
        link: report_human_resource_path }]
    end
end
