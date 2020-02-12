# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :account, module: "accounts" do
    resource :password, only: %i[show update]
    resource :profile, only: %i[show update]
    resources :jwts, only: %i[index create destroy] do
      collection do
        delete :clean_expired_jwts
      end
    end
  end

  namespace :api do
    resource :name_card, only: %i[create]

    match "me" => "application#user_info", via: :options
    match "sync_white_jwts" => "application#sync_white_jwts", via: :options

    resource :cad_session, only: %i[create]
    resource :cad_operation, only: %i[create]
  end

  namespace :admin do
    root to: "home#index"

    resources :users, except: %i[destroy] do
      member do
        patch :lock
        patch :unlock
        patch :resend_confirmation_mail
        patch :resend_invitation_mail
        patch :login_as
      end
    end

    resources :um_tasks, only: %i[index]
  end

  namespace :company do
    root to: "home#index"
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
    resources :contracts, only: %i[index show] do
      resources :sales_contracts, only: %i[show]
    end
    resource :contracts_map, only: %i[show] do
      collection do
        get :detail
      end
    end
  end

  namespace :report do
    root to: "home#index"

    resource :operation, only: %i[show]

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
    resource :group_workloading, only: %i[show]
    resource :subsidiary_workloading, only: %i[show] do
      collection do
        get :export
        get :day_rate_drill_down
        get :planning_day_rate_drill_down
        get :building_day_rate_drill_down
      end
    end
    resource :yearly_subsidiary_workloading, only: %i[show]
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
    resource :subsidiary_receive, only: %i[show]
    resource :subsidiary_department_receive, only: %i[show] do
      collection do
        get :real_data_drill_down
      end
    end
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
    resource :subsidiary_need_receive_sign_detail, only: %i[show] do
      member do
        patch :hide
        patch :un_hide
      end
    end
  end

  namespace :person do
    root to: 'home#index'

    resources :name_cards, only: %i[index new create show destroy] do
      member do
        patch :start_approve
      end
      collection do
        get :change_image
      end
    end
    resources :name_card_black_titles, only: %i[index create]
    resources :name_card_white_titles, only: %i[index create]

    resources :copy_of_business_licenses, only: %i[index new create destroy] do
      member do
        get :view_attachment
        patch :start_approve
      end
    end
    resources :proof_of_employments, only: %i[index new create destroy] do
      member do
        get :view_attachment
        patch :start_approve
      end
    end
    resources :proof_of_incomes, only: %i[index new create destroy] do
      member do
        get :view_attachment
        patch :start_approve
      end
    end
    resources :public_rental_housings, only: %i[index new create destroy] do
      member do
        get :view_attachment
        patch :start_approve
      end
    end
  end

  devise_for :users, skip: %i[registrations invitations], controllers: {
    confirmations: "users/confirmations",
    passwords: "users/passwords",
    sessions: "users/sessions"
  }

  devise_scope :user do
    resource :registrations,
             only: %i[new create],
             path: "users",
             path_names: { new: "sign_up" },
             controller: "users/registrations",
             as: :user_registration

    resource :invitations,
             only: %i[edit update],
             path: "users",
             controller: "users/invitations",
             as: :user_invitations
  end

  get "users", to: redirect("/users/sign_up")
  get 'auth/openid_connect/callback', to: 'openid_connect#callback'

  get "401", to: "errors#unauthorized", as: :unauthorized
  get "403", to: "errors#forbidden", as: :forbidden
  get "404", to: "errors#not_found", as: :not_found

  resource :wechat, only: [:show, :create]
  root to: "home#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
