# frozen_string_literal: true

namespace :report do
  root to: 'home#show'

  resource :key_customer_detail, only: %i[show]
  resource :organization_chart, only: %i[show]

  resource :operation, only: %i[show]

  resource :financial_management, only: %i[show]
  resource :dept_homepage, only: %i[show]
  resource :contract_information_form, only: %i[show]
  resource :project_contract_summary, only: %i[show]
  resource :departmental_market_fees, only: %i[show]
  resource :org_market_fees, only: %i[show]
  resource :bonus_distribution, only: %i[show]
  resource :labor_cost, only: %i[show]

  resource :human_resource, only: %i[show]

  resource :subsidiary_human_resource, only: %i[show]
  resource :hr_cjld, only: %i[show]
  resource :subsidiary_hr_cjld, only: %i[show]
  resource :hr_monthly_report_data_entry, only: %i[show]
  resource :hrdw_stfreinstate_bi_save, only: %i[show] do
    post :stfreinstate_archive
    post :stfturnover_archive
  end
  resource :group_hr_monthly, only: %i[show]
  resource :group_hr_monthly_pure, only: %i[show]
  resource :group_subsidiary_hr_monthly, only: %i[show]
  resource :group_subsidiary_hr_monthly_pure, only: %i[show]
  resource :rt_group_hr_monthly, only: %i[show]
  resource :rt_group_hr_monthly_pure, only: %i[show]
  resource :rt_group_subsidiary_hr_monthly, only: %i[show]
  resource :hr_talent_pool, only: %i[show]
  resource :hr_year_dismiss, only: %i[show]
  resource :single_project_overview, only: %i[show]
  resource :hr_core_staff_in_and_out, only: %i[show]
  resource :hr_staff_in_and_out, only: %i[show]

  resource :cost_allocation_summary_table, only: %i[show]

  resources :yingjianke_logins, only: %i[index destroy] do
    collection do
      get :export
    end
  end

  resources :tianzhen_logins, only: %i[index]
  resources :cim_tools, only: %i[index] do
    collection do
      get :report_sessions
      get :report_operations
      get :report_all
    end
  end
  resource :group_daily_workloading, only: %i[show]
  resource :subsidiary_daily_workloading, only: %i[show] do
    collection do
      get :export
      get :day_rate_drill_down
      get :planning_day_rate_drill_down
      get :building_day_rate_drill_down
    end
  end
  resource :subsidiary_people_workloading, only: %i[show] do
    collection do
      get :fill_dept_short_names
    end
  end
  resource :people_workloading, only: %i[show]
  resource :contract_signing, only: %i[show]
  resource :subsidiary_contract_signing, only: %i[show] do
    collection do
      get :drill_down_amount
      get :drill_down_date
      get :cp_drill_down
    end
  end
  resource :complete_value, only: %i[show]
  resource :subsidiary_complete_value, only: %i[show] do
    collection do
      get :drill_down
    end
  end
  resource :yearly_subsidiary_complete_value, only: %i[show]
  resource :subsidiary_receive, only: %i[show] do
    collection do
      get :need_receives_staff_drill_down
    end
  end
  resource :design_cash_flow, only: %i[show]
  resource :subsidiary_design_cash_flow, only: %i[show]
  resource :subsidiary_department_receive, only: %i[show] do
    collection do
      get :real_data_drill_down
      get :need_receives_pay_rates_drill_down
    end
  end
  resource :group_predict_contract, only: %i[show]
  resource :predict_contract, only: %i[show] do
    collection do
      get :opportunity_detail_drill_down
      get :signing_detail_drill_down
      get :fill_dept_names
    end
  end
  resource :project_milestore, only: %i[show] do
    get :detail_drill_down
    get :detail_table_drill_down
  end
  resource :contract_hold, only: %i[show] do
    collection do
      get :unsign_detail_drill_down
      get :export_unsign_detail
      get :sign_detail_drill_down
      get :export_sign_detail
      get :fill_dept_names
    end
  end
  resource :group_contract_hold, only: %i[show]
  resource :contract_sign_detail, only: %i[show] do
    member do
      patch :hide
      patch :un_hide
    end
  end
  resource :subsidiary_need_receive_unsign_detail, only: %i[show] do
    collection do
      get :org_name_change
    end
    member do
      patch :hide
      patch :un_hide
    end
  end
  resource :comment_on_sales_contract_code, only: %i[create]
  resource :comment_on_project_item_codes, only: %i[create]
  resource :subsidiary_need_receive_sign_detail, only: %i[show] do
    collection do
      get :org_name_change
      get :total_receivables_drill_down
      get :financial_receivables_drill_down
    end
    member do
      patch :hide
      patch :un_hide
    end
  end
  resource :overall_operating_status, only: %i[show]
  resource :subsidiaries_operating_comparison, only: %i[show]
  resource :national_market_share, only: %i[show]
  resource :contract_types_analysis, only: %i[show]
  resource :contracts_geographical_analysis, only: %i[show]
  resource :contract_provice_area, only: %i[show]
  resource :customer_analysis, only: %i[show]
  resource :year_report_history, only: %i[show]
  resource :crm_year_report, only: %i[show] do
    get :drill_down
    get :drill_down_dept_value
    get :drill_down_top_group
    get :drill_down_group_detail
    get :export
  end
  resource :customer_receivable_accounts
end
