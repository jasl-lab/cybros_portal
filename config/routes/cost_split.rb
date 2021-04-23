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
  resources :cost_allocation_monthly_flows, only: %i[index show] do
    member do
      patch :start_approve
    end
  end
  resources :cost_split_company_monthly_adjusts, only: %i[create]
end
