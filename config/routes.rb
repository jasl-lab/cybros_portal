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
    resource :group_expense_share_plan_approval, only: %i[create]
    resource :received_sms_message, only: %i[create show]

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

  draw :admin
  draw :company
  draw :we_market
  draw :report

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
  end

  namespace :operation_entry do
    root to: 'home#show'

    resource :cost_structure_entry, only: %i[show]
    resource :cash_flow_dept_entry, only: %i[show]
  end

  namespace :index_library do
    root to: 'home#show'

    resource :index_summary_table, only: %i[show]
  end

  namespace :account do
    resource :report, only: %i[show]
    resource :org_year_fill, only: %i[show]
    resource :org_month_fill, only: %i[show]
    resource :interior_fill, only: %i[show]
    resource :dept_year_fill, only: %i[show]
    resource :dept_month_fill, only: %i[show]
    resource :mergereport_account_fill, only: %i[show]
    resource :mergereport_analyzer_fill, only: %i[show]
    resource :business_target_org, only: %i[show]
    resource :business_target_org_show, only: %i[show]
    resource :business_target_dept, only: %i[show]
    resource :business_target_dept_show, only: %i[show]
    resource :business_target_sub_dept, only: %i[show]
    resource :operation_summary_org, only: %i[show]
    resource :operation_summary_dept, only: %i[show]
    resource :mergereport_final_check, only: %i[show]
    resource :split_setting, only: %i[show]
    resource :cost_report, only: %i[show]
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

  draw :cost_split

  namespace :ui do
    resource :ncworkno_select, only: %i[show]
    resource :userid_select, only: %i[show]
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
