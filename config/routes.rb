Rails.application.routes.draw do
  resources :employee_invitations, only: [ :edit, :update ], param: :token
  namespace :admin do
    get "monthly_attendance_closing_approvals/index"
    resources :employees do
      collection do
        get :subordinates
      end
      member do
        get :registration_link
      end
      resources :work_date_exception_requests, only: :index do
        post "approve_request", on: :member
        post "reject_request", on: :member
      end
      resources :attendance_edit_requests do
        post "approve_edit_request", on: :member
      end
      resources :monthly_attendance_closing_approvals, only: :index do
        post "approve_closing", on: :member
        post "reject_closing", on: :member
      end
      resources :employee_rules, only: [ :index, :new, :create ]
      resources :paid_leave_grants, only: [ :index, :new, :create ]
    end
  end
  root to: "attendances#show_today"
  resources :employees do
    resources :attendances, only: [ :index, :show, :update ], param: :worked_on do
      resource :attendance_edit_request
    end
    resources :attendance_edit_requests, only: :index
    resources :work_date_exception_requests, only: [ :new, :edit, :create, :update ]
    resources :monthly_attendance_closings, only: [ :index, :new, :create ]
  end
  resources :paid_leave_grants, only: :index
  resources :notifications, only: [ :index, :show ]
  devise_for :employees, path: "auth"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
