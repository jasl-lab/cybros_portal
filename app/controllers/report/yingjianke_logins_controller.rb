class Report::YingjiankeLoginsController < Report::BaseController
  include ActionView::Helpers::DateHelper
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")
    @rows = rows.sort { |a, b| (b[2] - b[1]) <=> (a[2] - a[1]) }[0...50]
  end

  def export
    respond_to do |format|
      format.csv do
        render_csv_header 'Yingjianke_Logins'
        csv_res = CSV.generate do |csv|
          csv << ['序号', '部门姓名', '登陆时间', '最后访问', '逗留时长', '机器', 'IP地址']
          idx = 0
          rows
          .sort { |a, b| (b[2] - b[1]) <=> (a[2] - a[1]) }
          .each do |r|
            if (r[2] - r[1]) * 24 >= 6
              idx += 1
              r[1] = r[1].to_s(:db)
              r[2] = r[2].to_s(:db)
              csv << [idx] + r
            end
          end
        end
        send_data "\xEF\xBB\xBF" << csv_res
      end
    end
  end

def rows
  response = HTTP.cookies('bsAutoLogin' => 'BIT_TRUE',
    'bsPassword' => Rails.application.credentials.yingjianke_admin_password!,
    'bsSessionID' => Rails.application.credentials.yingjianke_admin_session_id!,
    'bsUser' => Rails.application.credentials.yingjianke_admin_username!)
    .get(Rails.application.credentials.yingjianke_admin_web_url!)
  if response.code == 200
    html_doc = Nokogiri::HTML(response.body.to_s)
    trs = html_doc.xpath('//*[@id="content_middle"]/table/tbody/tr')
    rows = []
    trs.each do |tr, index|
      device = tr.elements[1].elements[0].content.strip
      user_name = device.split("@")[0]
      info = User.details_mapping.fetch(user_name, user_name)
      ip = tr.elements[2].content.strip
      login_time = DateTime.parse(tr.elements[3].content.strip)
      last_access_time =  DateTime.parse(tr.elements[4].content.strip)
      stay_time = distance_of_time_in_words login_time, last_access_time
      rows << [info, login_time, last_access_time, stay_time, device, ip]
    end
    rows
  end
end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.report.header"),
      link: report_root_path },
    { text: t("layouts.sidebar.report.yingjianke_logins"),
      link: report_yingjianke_logins_path }]
  end


  def set_page_layout_data
    @_sidebar_name = "report"
  end
end
