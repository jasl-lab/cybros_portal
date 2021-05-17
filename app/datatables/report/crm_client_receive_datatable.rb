# frozen_string_literal: true

module Report
  class CrmClientReceiveDatatable < ApplicationDatatable
    def initialize(params, opts = {})
      @crm_client_receives = opts[:crm_client_receives]
      @org_codes = opts[:org_codes]
      @client_name = opts[:client_name]
      super
    end

    def view_columns
      @view_columns ||= {
        crmthrank: { source: 'Bi::CrmClientReceive.crmthrank', cond: :string_eq, searchable: true, orderable: true },
        crmshort: { source: 'Bi::CrmClientReceive.crmshort', orderable: true },
        cricrank: { source: 'Bi::CrmClientReceive.cricrank', orderable: true },
        clientproperty: { source: 'Bi::CrmClientReceive.clientproperty', orderable: true },
        sum_receive: { source: 'Bi::CrmClientReceive.sum_receive', cond: :string_eq, searchable: true, orderable: true },
        sum_receive_gt1_years: { source: 'Bi::CrmClientReceive.sum_receive_gt1_years', cond: :like, searchable: true, orderable: true },

        aging_amount_lt3_months: { source: 'Bi::CrmClientReceive.aging_amount_lt3_months', orderable: true },
        aging_amount_4to12_months: { source: 'Bi::CrmClientReceive.aging_amount_4to12_months', orderable: true },
        aging_amount_gt1_years: { source: 'Bi::CrmClientReceive.aging_amount_gt1_years', orderable: true },
        sign_receive: { source: 'Bi::CrmClientReceive.sign_receive', orderable: true },
        unsign_receive_gt1_years: { source: 'Bi::CrmClientReceive.unsign_receive_gt1_years', orderable: true },
        unsign_receive_lteq1_years: { source: nil, orderable: false },
        unsign_receive: { source: 'Bi::CrmClientReceive.unsign_receive', orderable: true }
      }
    end

    def data
      records.map do |r|
        { crmthrank: r.crmthrank,
          crmshort: r.crmshort,
          cricrank: r.cricrank,
          clientproperty: r.clientproperty,
          sum_receive: (r.sum_receive.to_f / 10000.0).round(0),
          sum_receive_gt1_years: (r.sum_receive_gt1_years.to_f / 10000.0).round(0),

          aging_amount_lt3_months: (r.aging_amount_lt3_months.to_f / 10000.0).round(0),
          aging_amount_4to12_months: (r.aging_amount_4to12_months.to_f / 10000.0).round(0),
          aging_amount_gt1_years: (r.aging_amount_gt1_years.to_f / 10000.0).round(0),
          sign_receive: (r.sign_receive.to_f / 10000.0).round(0),
          unsign_receive_gt1_years: (r.unsign_receive_gt1_years.to_f / 10000.0).round(0),
          unsign_receive_lteq1_years: (r.unsign_receive.present? && r.unsign_receive_gt1_years.present? ? ((r.unsign_receive - r.unsign_receive_gt1_years) / 10000.0).round(0) : nil),
          unsign_receive: (r.unsign_receive.to_f / 10000.0).round(0)
       }
      end
    end

    def get_raw_records
      rr = @crm_client_receives
      rr = rr.where(orgcode_sum: @org_codes) if @org_codes.present?
      rr = rr.where('crmshort LIKE ?', "%#{@client_name}%") if @client_name.present?
      rr
    end
  end
end
