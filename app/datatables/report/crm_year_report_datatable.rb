# frozen_string_literal: true

module Report
  class CrmYearReportDatatable < ApplicationDatatable
    def_delegator :@view, :person_proof_of_employment_path

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

        total_contract_value_of_the_group_percent: { source: 'Bi::CrmClientSum.heji_per', cond: :like, searchable: true, orderable: true },
        the_top_three_teams_in_cooperation: { source: 'Bi::CrmClientSum.topthreegroup', cond: :like, searchable: true, orderable: true },
        scheme_production_contract_value_at_each_stage: { source: 'Bi::CrmClientSum.designvalue', cond: :like, searchable: true, orderable: true },
        construction_drawing_production_contract_value_at_each_stage: { source: 'Bi::CrmClientSum.constructionvalue', cond: :like, searchable: true, orderable: true },
        whole_process_production_contract_value_at_each_stage: { source: 'Bi::CrmClientSum.fullvalue', cond: :like, searchable: true, orderable: true },

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
          customer_group: r.crmshort,
          kerrey_trading_area_ranking: r.cricrank,
          customer_ownership: r.clientproperty,
          production_contract_value_last_year: r.heji_last,
          production_contract_value_this_year: r.heji,

          total_contract_value_of_the_group_percent: r.heji_per,
          the_top_three_teams_in_cooperation: r.topthreegroup,
          scheme_production_contract_value_at_each_stage: r.designvalue,
          construction_drawing_production_contract_value_at_each_stage: r.constructionvalue,
          whole_process_production_contract_value_at_each_stage: r.fullvalue,

          average_contract_value_of_single_project_in_the_past_year: nil,
          average_scale_of_single_project_in_the_past_year: nil,
          nearly_one_year_contract_average_contract_period: nil,
          proportion_of_contract_amount_modification_fee: nil,
          proportion_of_labor_cost_of_bidding_land_acquisition: nil
        }
      end
    end

    def get_raw_records
      @crm_client_sum.where(cricyear: @year)
    end
  end
end
