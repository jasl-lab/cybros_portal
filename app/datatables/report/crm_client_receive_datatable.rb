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
        crmthrank: { source: 'client_rank', searchable: false, orderable: true },
        crmshort: { source: 'Bi::CrmClientReceive.crmshort', searchable: true, orderable: true },
        cricrank: { source: 'Bi::CrmClientReceive.cricrank', searchable: false, orderable: true },
        clientproperty: { source: 'Bi::CrmClientReceive.clientproperty', cond: :string_eq, searchable: true, orderable: true },
        sum_receive: { source: 'sum_receive', searchable: false, orderable: true },
        sum_receive_gt1_years: { source: nil, searchable: false, orderable: true },

        aging_amount_lt3_months: { source: 'Bi::CrmClientReceive.aging_amount_lt3_months', orderable: true },
        aging_amount_4to12_months: { source: 'Bi::CrmClientReceive.aging_amount_4to12_months', orderable: true },
        aging_amount_gt1_years: { source: 'Bi::CrmClientReceive.aging_amount_gt1_years', orderable: true },
        sign_receive: { source: 'Bi::CrmClientReceive.sign_receive', orderable: true },
        unsign_receive_gt1_years: { source: 'Bi::CrmClientReceive.unsign_receive_gt1_years', orderable: true },
        unsign_receive: { source: 'Bi::CrmClientReceive.unsign_receive', orderable: true },

        acc_receive_lt3_months: { source: 'Bi::CrmClientReceive.acc_receive_lt3_months', orderable: true },
        acc_receive_4to12_months: { source: 'Bi::CrmClientReceive.acc_receive_4to12_months', orderable: true },
        acc_receive_gt1_years: { source: 'Bi::CrmClientReceive.acc_receive_gt1_years', orderable: true },
        acc_receive: { source: 'Bi::CrmClientReceive.acc_receive', orderable: true }
      }
    end

    def data
      records.map do |r|
        { crmthrank: r.client_rank,
          crmshort: r.crmshort,
          cricrank: (r.cricrank == 999999 ? '' : r.cricrank),
          clientproperty: r.clientproperty,
          sum_receive: (r.sum_receive.to_f / 10000.0).round(0),
          sum_receive_gt1_years: "#{((r.aging_amount_gt1_years.to_f / r.sum_receive.to_f) * 100.0).round(0)} %",

          aging_amount_lt3_months: (r.aging_amount_lt3_months.to_f / 10000.0).round(0),
          aging_amount_4to12_months: (r.aging_amount_4to12_months.to_f / 10000.0).round(0),
          aging_amount_gt1_years: (r.aging_amount_gt1_years.to_f / 10000.0).round(0),
          sign_receive: (r.sign_receive.to_f / 10000.0).round(0),
          unsign_receive_gt1_years: (r.unsign_receive_gt1_years.to_f / 10000.0).round(0),
          unsign_receive: (r.unsign_receive.to_f / 10000.0).round(0),

          acc_receive_lt3_months: (r.acc_receive_lt3_months.to_f / 10000.0).round(0),
          acc_receive_4to12_months: (r.acc_receive_4to12_months.to_f / 10000.0).round(0),
          acc_receive_gt1_years: (r.acc_receive_gt1_years.to_f / 10000.0).round(0),
          acc_receive: (r.acc_receive.to_f / 10000.0).round(0)
       }
      end
    end

    def get_raw_records
      rr = @crm_client_receives
      rr = rr.where(orgcode_sum: @org_codes) if @org_codes.present?
      rr = if @client_name.present?
        rr.where(crmcode: Bi::CrmClientInfo.crmcode_from_query_names(@client_name))
      else
        rr
      end
      rr.select('crmcode, crmshort, cricrank, clientproperty, DENSE_RANK() OVER (ORDER BY SUM(sum_receive) DESC) client_rank,
        SUM(sum_receive) sum_receive,
        SUM(aging_amount_lt3_months) aging_amount_lt3_months, SUM(aging_amount_4to12_months) aging_amount_4to12_months,
        SUM(aging_amount_gt1_years) aging_amount_gt1_years, SUM(sign_receive) sign_receive,
        SUM(unsign_receive_gt1_years) unsign_receive_gt1_years, SUM(unsign_receive) unsign_receive,
        SUM(acc_receive_lt3_months) acc_receive_lt3_months, SUM(acc_receive_4to12_months) acc_receive_4to12_months,
        SUM(acc_receive_gt1_years) acc_receive_gt1_years, SUM(acc_receive) acc_receive')
        .group('crmcode, crmshort, cricrank, clientproperty')
    end
  end
end
