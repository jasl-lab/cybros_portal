# frozen_string_literal: true

class CadSessionDatatable < ApplicationDatatable
  include ActionView::Helpers::TagHelper

  def initialize(params, opts = {})
    @cad_sessions = opts[:cad_sessions]
    super
  end

  def view_columns
    @view_columns ||= {
      session: { source: "Cad::CadSession.session", cond: :string_eq, searchable: true, orderable: true },
      begin_operation: { source: "Cad::CadSession.begin_operation", cond: :string_eq, searchable: true, orderable: true },
      operation: { source: "Cad::CadSession.operation", cond: :string_eq, searchable: true, orderable: true },
      end_operation: { source: "Cad::CadSession.end_operation", cond: :string_eq, searchable: true, orderable: true },
      ip_address: { source: "Cad::CadSession.ip_address", cond: :like, searchable: true, orderable: true },
      mac_address: { source: "Cad::CadSession.mac_address", cond: :like, orderable: true },
      created_at: { source: "Cad::CadSession.created_at", orderable: true },
      updated_at: { source: "Cad::CadSession.updated_at", orderable: true }
    }
  end

  def data
    records.map do |r|
      { session: r.session,
        begin_operation: r.begin_operation,
        operation: r.operation,
        end_operation: "#{r.end_operation}".html_safe,
        ip_address: r.ip_address,
        mac_address: tag.div(r.mac_address, class: "text-center"),
        created_at: tag.div(r.created_at, class: "text-center"),
        updated_at: tag.div(r.updated_at, class: "text-center")
     }
    end
  end

  def get_raw_records
    @cad_sessions
  end
end
