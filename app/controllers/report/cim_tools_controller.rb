# frozen_string_literal: true

class Report::CimToolsController < Report::BaseController
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
  end

  def report_sessions
    authorize Cad::CadSession

    respond_to do |format|
      format.csv do
        render_csv_header 'CAD session report'
        csv_res = CSV.generate do |csv|
          csv << ['ID', 'Session', 'Operation', 'IP address', 'MAC address', 'User ID', 'Created At']
          policy_scope(Cad::CadSession).order(id: :asc).find_each do |s|
            values = []
            values << s.id
            values << s.session
            values << s.operation
            values << s.ip_address
            values << s.mac_address
            values << s.user_id
            values << s.created_at
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF#{csv_res}"
      end
    end
  end

  def report_operations
    authorize Cad::CadOperation

    respond_to do |format|
      format.csv do
        render_csv_header 'CAD operation report'
        csv_res = CSV.generate do |csv|
          csv << ['ID', 'Session', 'CMD name', 'CMD seconds', 'CMD data', 'User ID', 'Created At']
          policy_scope(Cad::CadOperation).order(id: :asc).find_each do |s|
            values = []
            values << s.id
            values << s.session_id
            values << s.cmd_name
            values << s.cmd_data
            values << s.user_id
            values << s.created_at
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF#{csv_res}"
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
      { text: t("layouts.sidebar.report.cim_tools"),
        link: report_cim_tools_path }]
    end


    def set_page_layout_data
      @_sidebar_name = "report"
    end
end
