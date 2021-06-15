# frozen_string_literal: true

module Report
  class CrmClientReceiveDatatable < ApplicationDatatable
    def initialize(params, opts = {})
      @crm_client_receives = opts[:crm_client_receives]
      @org_codes = opts[:org_codes]
      super
    end

    def view_columns
      @view_columns ||= {
        crmthrank: { source: 'client_rank', searchable: false, orderable: true },
        crmshort: { source: nil, searchable: false, orderable: false },
        cricrank: { source: 'Bi::CrmClientReceive.cricrank', searchable: false, orderable: true },
        clientproperty: { source: 'Bi::CrmClientReceive.clientproperty', cond: :string_eq, searchable: true, orderable: true },
        sum_receive: { source: 'sum_receive', searchable: false, orderable: true },
        sum_receive_gt1_years: { source: nil, searchable: false, orderable: true },

        aging_amount_lt3_months: { source: 'aging_amount_lt3_months', orderable: true },
        aging_amount_4to12_months: { source: 'aging_amount_4to12_months', orderable: true },
        aging_amount_gt1_years: { source: 'aging_amount_gt1_years', orderable: true },
        sign_receive: { source: 'sign_receive', orderable: true },
        unsign_receive: { source: 'unsign_receive', orderable: true }
      }
    end

    def data
      records.map do |r|
        { crmthrank: r.client_rank,
          crmshort: Bi::CrmClientInfo.crm_short_names.fetch(r.crmcode, nil),
          cricrank: (r.cricrank == 999999 ? '' : r.cricrank),
          clientproperty: r.clientproperty,
          sum_receive: (r.sum_receive.to_f / 10000.0).round(0),
          sum_receive_gt1_years: "#{((r.aging_amount_gt1_years.to_f / r.sum_receive.to_f) * 100.0).round(0)} %",

          aging_amount_lt3_months: (r.aging_amount_lt3_months.to_f / 10000.0).round(0),
          aging_amount_4to12_months: (r.aging_amount_4to12_months.to_f / 10000.0).round(0),
          aging_amount_gt1_years: (r.aging_amount_gt1_years.to_f / 10000.0).round(0),
          sign_receive: (r.sign_receive.to_f / 10000.0).round(0),
          unsign_receive: (r.unsign_receive.to_f / 10000.0).round(0)
       }
      end
    end

    def get_raw_records
      rr = @crm_client_receives
      rr = rr.where(orgcode_sum: @org_codes) if @org_codes.present?
      rr.select('crmcode, cricrank, clientproperty, DENSE_RANK() OVER (ORDER BY SUM(sum_receive) DESC) client_rank, SUM(sum_receive) sum_receive, SUM(aging_amount_lt3_months) aging_amount_lt3_months, SUM(aging_amount_4to12_months) aging_amount_4to12_months, SUM(aging_amount_gt1_years) aging_amount_gt1_years, SUM(sign_receive) sign_receive, SUM(unsign_receive_gt1_years) unsign_receive_gt1_years, SUM(unsign_receive) unsign_receive')
        .group('crmcode, cricrank, clientproperty')
    end
  end
end
