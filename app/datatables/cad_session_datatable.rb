# frozen_string_literal: true

class CadSessionDatatable < ApplicationDatatable
  include ActionView::Helpers::TagHelper

  def initialize(params, opts = {})
    @cad_sessions = opts[:cad_sessions]
    super
  end

  def view_columns
    @view_columns ||= {
      user_name: { source: 'User.chinese_name', cond: :string_eq, searchable: true, orderable: true },
      user_company: { source: 'User.user_company_short_name', orderable: true },
      user_department: { source: 'User.user_department_name', orderable: true },
      user_title: { source: 'User.position_title', orderable: true },
      operation: { source: 'Cad::CadSession.operation', cond: :string_eq, searchable: true, orderable: true },
      ip_mac_address: { source: 'Cad::CadSession.ip_address', cond: :like, searchable: true, orderable: true },
      created_at: { source: 'Cad::CadSession.created_at', orderable: true },
      updated_at: { source: 'Cad::CadSession.updated_at', orderable: true }
    }
  end

  def data
    records.map do |r|
      { user_name: r.user.chinese_name,
        user_company: r.user.user_company_short_name,
        user_department: r.user.user_department_name,
        user_title: r.user.position_title,
        operation: r.operation,
        ip_mac_address: "#{r.ip_address}#{tag.div(r.mac_address, class: "text-center")}".html_safe,
        created_at: tag.div(r.created_at, class: 'text-center'),
        updated_at: tag.div(r.updated_at, class: 'text-center')
     }
    end
  end

  def get_raw_records
    @cad_sessions.includes(user: :departments)
  end
end
