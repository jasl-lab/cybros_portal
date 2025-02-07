# frozen_string_literal: true

class Report::TianzhenLoginsController < Report::BaseController
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t('.title')
    response = HTTP.cookies('bsAutoLogin' => 'BIT_TRUE',
      'bsPassword' => '',
      'bsSessionID' => Rails.application.credentials.tianzhen_admin_session_id!,
      'bsUser' => Rails.application.credentials.tianzhen_admin_username!)
      .get(Rails.application.credentials.tianzhen_admin_web_url!)
    if response.code == 200
      html_doc = Nokogiri::HTML(response.body.to_s)
      trs = html_doc.xpath('//*[@id="content_middle"]/table/tbody/tr')
      @rows = []
      trs.each do |tr|
        idx = tr.elements[0].content.strip
        user = tr.elements[1].content.strip
        ip = tr.elements[2].content.strip
        login_time = Time.zone.parse(tr.elements[3].content.strip)
        last_access_time = Time.zone.parse(tr.elements[4].content.strip)
        @rows << [idx, user, ip, login_time, last_access_time]
      end
      @rows = @rows.sort { |a, b| (b[4] - b[3]) <=> (a[4] - a[3]) }
    end
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.report.header'),
        link: report_root_path },
      { text: t('layouts.sidebar.report.tianzhen_logins'),
        link: report_tianzhen_logins_path }]
    end


    def set_page_layout_data
      @_sidebar_name = 'report'
    end
end
