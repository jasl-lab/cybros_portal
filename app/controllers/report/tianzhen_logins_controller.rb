class Report::TianzhenLoginsController < ApplicationController
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")
    last_500_lines = `tail -n 500 /mnt/tianzhen_log/天正软件.log`.encode('gbk','utf-8',{:invalid => :replace, :undef => :replace, :replace => '?'})
    @hash = {}
    r = Regexp.new('^(\d+\-\d+\-\d+\s\d+\:\d+\:\d+)\s\[(\w*)\]\s(\d+\.\d+\.\d+\.\d+)\s(\w+@\w+)\s(.*)$')
    last_500_lines.split("\n").each do |l|
      r.match(l) do |m|
        time = DateTime.parse(m[1])
        action = m[2]
        ip = m[3]
        pc = m[4]
        line = m[5]
        hv = @hash.fetch("#{ip} #{pc}", [])
        hv << [action, time, line]
        @hash["#{ip} #{pc}"] = hv
      end
    end
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.report.header"),
      link: report_root_path },
    { text: t("layouts.sidebar.report.tianzhen_logins"),
      link: report_tianzhen_logins_path }]
  end


  def set_page_layout_data
    @_sidebar_name = "report"
  end
end
