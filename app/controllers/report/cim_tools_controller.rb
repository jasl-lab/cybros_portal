# frozen_string_literal: true

class Report::CimToolsController < Report::BaseController
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_breadcrumbs, only: %i[index], if: -> { request.format.html? }

  def index
    authorize Cad::CadSession
    prepare_meta_tags title: t('.title')

    respond_to do |format|
      format.html
      format.json do
        cad_sessions = policy_scope(Cad::CadSession)
        render json: CadSessionDatatable.new(params,
          cad_sessions: cad_sessions,
          view_context: view_context)
      end
    end
  end

  def report_sessions
    authorize Cad::CadSession

    respond_to do |format|
      format.csv do
        render_csv_header 'CAD session report'
        csv_res = CSV.generate do |csv|
          csv << ['ID', 'Session', 'Begin Operation', 'Operation', 'End Operation', 'IP address', 'MAC address', 'User ID', 'User email', 'User Name', 'User title', 'Created at', 'Updated at']
          policy_scope(Cad::CadSession).includes(:user).order(id: :asc).find_each do |s|
            values = []
            values << s.id
            values << s.session
            values << s.begin_operation
            values << s.operation
            values << s.end_operation
            values << s.ip_address
            values << s.mac_address
            values << s.user_id
            values << s.user.email
            values << s.user.chinese_name
            values << s.user.position_title
            values << s.created_at
            values << s.updated_at
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF#{csv_res}", filename: 'CAD session report.csv'
      end
    end
  end

  def report_operations
    authorize Cad::CadOperation

    respond_to do |format|
      format.csv do
        render_csv_header 'CAD operation report'
        csv_res = CSV.generate do |csv|
          csv << ['ID', 'Session', 'CMD name', 'CMD seconds', 'CMD data', 'SEG name', 'SEG function', 'User ID', 'User email', 'User Name', 'User title', 'Created At']
          policy_scope(Cad::CadOperation).includes(:user).order(id: :asc).find_each do |s|
            values = []
            values << s.id
            values << s.session_id
            values << s.cmd_name
            values << s.cmd_data
            values << s.seg_name
            values << s.seg_function
            values << s.user_id
            values << s.user.email
            values << s.user.chinese_name
            values << s.user.position_title
            values << s.created_at
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF#{csv_res}", filename: 'CAD operation report.csv'
      end
    end
  end

  def report_all
    authorize Cad::CadSession

    respond_to do |format|
      format.csv do
        render_csv_header 'CAD usage detail report'
        csv_res = CSV.generate do |csv|
          csv << ['ID', 'Session', 'Begin Operation', 'Operation', 'End Operation', 'IP address', 'MAC address',
            'User ID', 'User email', 'User Name', 'User company', 'User department', 'User title', 'User leave date',
            'CMD name', 'CMD seconds', 'CMD data', 'SEG name', 'SEG function', 'Created at', 'Updated at']
          policy_scope(Cad::CadSession).includes(:user).order(id: :asc).find_each do |s|
            if s.operations.blank?
              values = []
              values << s.id
              values << s.session
              values << s.begin_operation
              values << s.operation
              values << s.end_operation
              values << s.ip_address
              values << s.mac_address
              values << s.user_id
              values << s.user.email
              values << s.user.chinese_name
              values << s.user.user_company_short_name
              values << s.user.user_department_name
              values << s.user.position_title
              values << s.user.locked_at
              values << ''
              values << ''
              values << ''
              values << ''
              values << ''
              values << s.created_at
              values << s.updated_at
              csv << values
            else
              s.operations.each do |o|
                values = []
                values << s.id
                values << s.session
                values << s.begin_operation
                values << s.operation
                values << s.end_operation
                values << s.ip_address
                values << s.mac_address
                values << s.user_id
                values << s.user.email
                values << s.user.chinese_name
                values << s.user.user_company_short_name
                values << s.user.user_department_name
                values << s.user.position_title
                values << o.cmd_name
                values << o.cmd_seconds
                values << o.cmd_data
                values << o.seg_name
                values << o.seg_function
                values << o.created_at
                values << o.updated_at
                csv << values
              end
            end
          end
        end
        send_data "\xEF\xBB\xBF#{csv_res}", filename: 'CAD usage detail report.csv'
      end
    end
  end

  private

    def set_breadcrumbs
      @_breadcrumbs = [
      { text: t('layouts.sidebar.application.header'),
        link: root_path },
      { text: t('layouts.sidebar.report.header'),
        link: report_root_path },
      { text: t('layouts.sidebar.report.cim_tools'),
        link: report_cim_tools_path }]
    end


    def set_page_layout_data
      @_sidebar_name = 'report'
    end
end
