class Report::YingjiankeLoginsController < Report::BaseController
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")
    @rows = YingjiankeOverrunUser.rows.sort { |a, b| (b[2] - b[1]) <=> (a[2] - a[1]) }[0...50]
    if DateTime.now.new_offset('+8:00').hour >= 8
      @user_num = Array.new((DateTime.now.new_offset('+8:00').hour - 8) / 2 + 1, [0, 0, 0])
    else
      @user_num = []
    end
    YingjiankeOverrunUser.all.each do |u|
      if u.time.in_time_zone.to_date === DateTime.now.new_offset('+8:00').to_date
        if u.stay_timespan >= 18
          @user_num[(u.time.in_time_zone.hour - 8)/2][2] += 1
        elsif u.stay_timespan >= 12
          @user_num[(u.time.in_time_zone.hour - 8)/2][1] += 1
        elsif u.stay_timespan >= 6
          @user_num[(u.time.in_time_zone.hour - 8)/2][1] += 1
        end
      end
    end
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
