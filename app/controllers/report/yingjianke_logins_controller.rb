# frozen_string_literal: true

class Report::YingjiankeLoginsController < Report::BaseController
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
    prepare_meta_tags title: t(".title")
    @rows = YingjiankeOverrunUser.rows.sort { |a, b| (b[2] - b[1]) <=> (a[2] - a[1]) }
    @user_8am = count_yjk_user(Time.current.beginning_of_day + 8 * 60 * 60)
    @user_10am = count_yjk_user(Time.current.beginning_of_day + 10 * 60 * 60)
    @user_12am = count_yjk_user(Time.current.beginning_of_day + 12 * 60 * 60)
    @user_14pm = count_yjk_user(Time.current.beginning_of_day + 14 * 60 * 60)
    @user_17pm = count_yjk_user(Time.current.beginning_of_day + 17 * 60 * 60)
  end

  def export
    respond_to do |format|
      format.csv do
        render_csv_header "Yingjianke_Logins"
        csv_res = CSV.generate do |csv|
          csv << %w[序号 部门姓名 登陆时间 最后访问 逗留时长 机器 IP地址]
          YingjiankeOverrunUser.rows.sort { |a, b| (b[2] - b[1]) <=> (a[2] - a[1]) }
            .each_with_index do |r, idx|
            r[1] = r[1].to_s(:db)
            r[2] = r[2].to_s(:db)
            csv << [idx + 1] + r
          end
        end
        send_data "\xEF\xBB\xBF#{csv_res}"
      end
    end
  end

  private

    def count_yjk_user(time)
      YingjiankeOverrunUser.where(created_at: (time - 5.minutes)..(time + 5.minutes)).reduce([0, 0, 0]) do |h, yjk|
        case
        when yjk.stay_timespan > 18
          h[2] += 1
        when yjk.stay_timespan > 12
          h[1] += 1
        else
          h[0] += 1
        end
        h
      end
    end

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
