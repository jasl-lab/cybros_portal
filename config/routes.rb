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
    match "me" => "application#user_info", via: :options
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
      resources :knowledges, only: %i[show] do
        member do
          get :modal
        end
      end
    end

    resources :knowledge_maintains, except: [:show]
  end

  namespace :report do
    root to: "home#index"

    resources :tianzhen_logins, only: %i[index]
    resource :subsidiary_workloading, only: %i[show] do
      collection do
        get :export
      end
    end
    resource :yearly_subsidiary_workloading, only: %i[show]
    resource :contract_signing, only: %i[show]
  end

  namespace :person do
    root to: "home#index"

    resources :name_cards, only: %i[index new create show destroy] do
      member do
        patch :start_approve
      end
    end
    resources :name_card_black_titles, only: %i[index create]
    resources :name_card_white_titles, only: %i[index create]
  end

  namespace :api do
    resource :name_card, only: %i[create]
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
