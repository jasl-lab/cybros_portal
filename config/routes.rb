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
    resource :project_map, only: [:show] do
      member do
        get 'query_config'
        get 'project'
        get 'project_contracts'
        get 'project_contract'
        get 'list'
      end
    end
  end

  namespace :admin do
    root to: 'home#index'

    resources :users, except: %i[destroy] do
      resources :manual_operation_access_codes, only: %i[destroy create]
      resources :manual_hr_access_codes, only: %i[destroy create]
      resources :manual_cw_access_codes, only: %i[destroy create]
      resources :manual_pts_access_codes, only: %i[destroy create]
      resources :manual_pt_special_access_codes, only: %i[destroy create]
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

    resources :roles, only: %i[index show update] do
      member do
        delete :user
      end
    end

    resources :manual_operation_access_codes, only: %i[index destroy]
    resource :bi_dept_structures, only: %i[show]
    resource :bi_view_histories, only: %i[show]
  end

  draw :routes_company

  draw :routes_report

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
    resource :business_target_sub_dept, only: %i[show]
    resource :operation_summary_org, only: %i[show]
    resource :operation_summary_dept, only: %i[show]

    resource :split_setting, only: %i[show]
  end

  namespace :capital do
    resource :report, only: %i[show]
    resource :fund_daily_fill, only: %i[show]
    resource :fund_daily_fill_missing, only: %i[show create]
    resource :summary_fund_sum, only: %i[show]
    resource :summary_fund_daily, only: %i[show]
    resource :summary_fund_week, only: %i[show]
    resource :summary_fund_month, only: %i[show]
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
    resources :set_special_person_costs, except: %i[new]
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
