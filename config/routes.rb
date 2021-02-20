# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :account, module: 'accounts' do
    resource :password, only: %i[show update]
    resource :profile, only: %i[show update]
    resources :jwts, only: %i[index create destroy] do
      collection do
        delete :clean_expired_jwts
      end
    end
  end

  devise_for :wechat_users, skip: :all
  namespace :api do
    resource :name_card, only: %i[create]
    resource :official_seal_usage, only: %i[create]

    match 'me' => 'application#user_info', via: :options
    match 'sync_white_jwts' => 'application#sync_white_jwts', via: :options

    resource :cad_session, only: %i[create]
    resource :cad_operation, only: %i[create]
    
    resource :wechat_mini_session, only: [:create]
    resource :wechat_mini_user, only: [:show, :update] do
      member do
        post 'mobile'
      end
    end
  end

  namespace :admin do
    root to: 'home#index'

    resources :users, except: %i[destroy] do
      resources :manual_operation_access_codes, only: %i[destroy create]
      resources :manual_hr_access_codes, only: %i[destroy create]
      resources :manual_cw_access_codes, only: %i[destroy create]
      collection do
        get :operation_org_code_change
        get :hr_org_code_change
        get :cw_org_code_change
      end
      member do
        patch :lock
        patch :unlock
        patch :resend_confirmation_mail
        patch :resend_invitation_mail
        patch :login_as
      end
    end

    resources :roles, only: %i[index show] do
      member do
        delete :user
      end
    end

    resources :manual_operation_access_codes, only: %i[index destroy]
    resource :bi_view_histories, only: %i[show]
  end

  namespace :company do
    root to: 'home#index'
    resource :home, only: %i[] do
      resources :knowledges, only: %i[index show] do
        member do
          get :modal
        end
      end
    end

    resources :knowledge_maintains, except: [:show] do
      collection do
        get :export
        get :list
      end
    end
    resources :pending_questions, only: %i[index create destroy update]
    resources :direct_questions, only: %i[index create destroy]
    resource :drill_down_question, only: %i[show]
    resources :official_stamp_usages, except: %i[edit update] do
      member do
        get :view_attachment
        patch :start_approve
      end
      collection do
        get :fill_application_subclasses
      end
    end
    resources :contracts, only: %i[index show] do
      resources :sales_contracts, only: %i[show]
    end
    resource :contracts_map, only: %i[show] do
      collection do
        get :detail
        get :project
      end
    end
    resource :zhaofeng_map, only: %i[show]
    resource :km_map, only: %i[show] do
      collection do
        get :fill_department
        get :fill_category
        get :fill_city
        get :fill_progress
        get :show_model
      end
    end
  end

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
      member do
        patch :hide
        patch :un_hide
      end
    end
    resource :comment_on_sales_contract_code, only: %i[create]
    resource :comment_on_project_item_codes, only: %i[create]
    resource :subsidiary_need_receive_sign_detail, only: %i[show] do
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
  end

  namespace :person do
    root to: 'home#index'

    resources :name_cards, except: %i[:update] do
      member do
        patch :start_approve
        patch :upload_name_card
      end
      collection do
        get :change_image
        get :report
        get :download_name_card
      end
    end
    resources :name_card_black_titles, only: %i[index create]
    resources :name_card_white_titles, only: %i[index create]

    resources :copy_of_business_licenses, except: %i[edit update] do
      member do
        get :view_attachment
        patch :start_approve
      end
    end
    resources :proof_of_employments, except: %i[edit update] do
      member do
        get :view_attachment
        patch :start_approve
      end
    end
    resources :proof_of_incomes, except: %i[edit update] do
      member do
        get :view_attachment
        patch :start_approve
      end
    end
    resources :public_rental_housings, except: %i[edit update] do
      member do
        get :view_attachment
        patch :start_approve
      end
    end
  end

  namespace :operation_entry do
    root to: 'home#show'

    resource :cost_structure_entry, only: %i[show]
    resource :cash_flow_dept_entry, only: %i[show]
  end

  namespace :account do
    resource :report, only: %i[show]
    resource :org_year_fill, only: %i[show]
    resource :org_month_fill, only: %i[show]
    resource :interior_fill, only: %i[show]
    resource :dept_year_fill, only: %i[show]
    resource :dept_month_fill, only: %i[show]
    resource :business_target_org, only: %i[show]
    resource :business_target_org_show, only: %i[show]
    resource :business_target_dept, only: %i[show]
    resource :business_target_dept_show, only: %i[show]
    resource :operation_summary_org, only: %i[show]
    resource :operation_summary_dept, only: %i[show]
  end

  namespace :capital do
    resource :report, only: %i[show]
    resource :fund_daily_fill, only: %i[show]
    resource :fund_daily_fill_missing, only: %i[show create]
    resource :summary_fund_daily, only: %i[show]
    resource :salary_query, only: %i[show]
  end

  namespace :cost_split do
    root to: 'home#show'

    resources :human_resources, only: %i[index] do
      collection do
        get :change_company
      end
    end
    resources :set_baseline_job_types, only: %i[index edit update show]
    resources :set_special_person_costs, only: %i[index]
    resources :set_part_time_person_costs, only: %i[index edit update] do
      collection do
        get :part_time_people
      end
    end
    resources :user_split_cost_settings, only: %i[new create edit update] do
      member do
        patch :reject
        patch :submit
      end
    end
    resources :split_cost_items, only: %i[index edit update] do
      member do
        patch :reject
        patch :submit
      end
    end
    resources :allocation_bases, only: %i[index create new update edit]

    resource :cost_allocation_summary, only: %i[show] do
      collection do
        get :drill_down_user
        get :drill_down_item
        get :drill_down_expenditure
      end
    end
  end

  namespace :ui do
    resource :ncworkno_select, only: %i[show]
  end

  devise_for :users, skip: %i[registrations invitations], controllers: {
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    sessions: 'users/sessions'
  }

  devise_scope :user do
    resource :registrations,
             only: %i[new create],
             path: 'users',
             path_names: { new: 'sign_up' },
             controller: 'users/registrations',
             as: :user_registration

    resource :invitations,
             only: %i[edit update],
             path: 'users',
             controller: 'users/invitations',
             as: :user_invitations
  end

  get '/users/logout' => 'home#logout'
  get 'users', to: redirect('/users/sign_up')
  get 'auth/openid_connect/callback', to: 'openid_connect#callback'

  get '401', to: 'errors#unauthorized', as: :unauthorized
  get '403', to: 'errors#forbidden', as: :forbidden

  resource :wechat, only: [:show, :create]
  root to: 'home#index'
end
