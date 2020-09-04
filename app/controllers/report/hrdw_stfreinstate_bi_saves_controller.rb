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
  end

  def stfturnover_archive
  end


  protected

  def set_page_layout_data
    @_sidebar_name = "human_resource"
  end

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.human_resource.header"),
      link: report_human_resource_path }]
  end
end
