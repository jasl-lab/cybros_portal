# frozen_string_literal: true

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
      get :print_all
    end
  end
  resources :sms_phone_configurations, only: %i[index edit update new create]
  resources :pending_questions, only: %i[index create destroy update]
  resources :direct_questions, only: %i[index create destroy]
  resource :drill_down_question, only: %i[show]
  resources :contracts, only: %i[index show] do
    resources :sales_contracts, only: %i[show]
  end
  resource :contracts_map, only: %i[show] do
    collection do
      get :detail
      get :project
    end
  end
  resources :joint_review_sms, only: %i[index]
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
