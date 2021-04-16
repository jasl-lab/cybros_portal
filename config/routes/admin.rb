# frozen_string_literal: true

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
  resources :baseline_position_accesses, only: %i[index edit update show]
  resources :received_sms_messages, only: %i[index]
  resource :bi_dept_structures, only: %i[show]
  resource :bi_view_histories, only: %i[show]
end
