# frozen_string_literal: true

module Report
  class CrmYearReportDatatable < ApplicationDatatable
    def_delegator :@view, :drill_down_dept_value_report_crm_year_report_path
    def_delegator :@view, :drill_down_top_group_report_crm_year_report_path

    def initialize(params, opts = {})
      @crm_client_sum = opts[:crm_client_sum]
      @year = opts[:year]
      super
    end

    def view_columns
      @view_columns ||= {
        rank: { source: nil, searchable: false, orderable: false },
        customer_group: { source: 'Bi::CrmClientSum.crmshort', cond: :string_eq, searchable: true, orderable: true },
        kerrey_trading_area_ranking: { source: 'Bi::CrmClientSum.cricrank', searchable: false, orderable: true },
        customer_ownership: { source: 'Bi::CrmClientSum.clientproperty', cond: :string_eq, searchable: true, orderable: true },
        production_contract_value_last_year: { source: 'Bi::CrmClientSum.heji_last', searchable: false, orderable: true },
        production_contract_value_this_year: { source: 'Bi::CrmClientSum.heji', searchable: false, orderable: true },

        total_contract_value_of_the_group_percent: { source: 'Bi::CrmClientSum.heji_per', searchable: false, orderable: true },
        the_top_three_teams_in_cooperation: { source: 'Bi::CrmClientSum.topthreegroup', cond: :like, searchable: true, orderable: true },
        scheme_production_contract_value_at_each_stage: { source: 'Bi::CrmClientSum.designvalue', searchable: false, orderable: true },
        construction_drawing_production_contract_value_at_each_stage: { source: 'Bi::CrmClientSum.constructionvalue', searchable: false, orderable: true },
        whole_process_production_contract_value_at_each_stage: { source: 'Bi::CrmClientSum.fullvalue', searchable: false, orderable: true },

        average_contract_value_of_single_project_in_the_past_year: { source: nil, searchable: false, orderable: false },
        average_scale_of_single_project_in_the_past_year: { source: nil, searchable: false, orderable: false },
        nearly_one_year_contract_average_contract_period: { source: nil, searchable: false, orderable: false },
        proportion_of_contract_amount_modification_fee: { source: nil, searchable: false, orderable: false },
        proportion_of_labor_cost_of_bidding_land_acquisition: { source: nil, searchable: false, orderable: false }
      }
    end

    def data
      records.map do |r|
        { rank: 1,
          customer_group: (link_to r.crmshort, drill_down_dept_value_report_crm_year_report_path(crmcode: r.crmcode, year: @year), remote: true),
          kerrey_trading_area_ranking: r.cricrank&.round(0),
          customer_ownership: r.clientproperty,
          production_contract_value_last_year: (r.heji_last.to_f / 10000.0).round(0),
          production_contract_value_this_year: (r.heji.to_f / 10000.0).round(0),

          total_contract_value_of_the_group_percent: (r.heji_per.to_f * 100.0).round(1),
          the_top_three_teams_in_cooperation: "#{r.topthreegroup} #{link_to('查看更多', drill_down_top_group_report_crm_year_report_path(crmcode: r.crmcode, year: @year), remote: true)}".html_safe,
          scheme_production_contract_value_at_each_stage: (r.designvalue.to_f / 10000.0).round(0),
          construction_drawing_production_contract_value_at_each_stage: (r.constructionvalue.to_f / 10000.0).round(0),
          whole_process_production_contract_value_at_each_stage: (r.fullvalue.to_f / 10000.0).round(0),

          average_contract_value_of_single_project_in_the_past_year: (Bi::CrmClientOneYear.by_crmcode.fetch(r.crmcode, nil)&.fetch(:avgamount, 0).to_f / 10000.0).round(0),
          average_scale_of_single_project_in_the_past_year: (Bi::CrmClientOneYear.by_crmcode.fetch(r.crmcode, nil)&.fetch(:avgarea, 0).to_f / 10000.0).round(0),
          nearly_one_year_contract_average_contract_period: Bi::CrmClientOneYear.by_crmcode.fetch(r.crmcode, nil)&.fetch(:avgsignday, 0)&.round(0),
          proportion_of_contract_amount_modification_fee: (Bi::CrmClientOneYear.by_crmcode.fetch(r.crmcode, nil)&.fetch(:contractalter, 0).to_f * 100.0).round(1),
          proportion_of_labor_cost_of_bidding_land_acquisition: (Bi::CrmClientOneYear.by_crmcode.fetch(r.crmcode, nil)&.fetch(:landhrcost, 0).to_f * 100.0).round(1)
        }
      end
    end

    def get_raw_records
      @crm_client_sum.where(cricyear: @year)
    end
  end
end
