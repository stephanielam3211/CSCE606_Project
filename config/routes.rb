# frozen_string_literal: true

Rails.application.routes.draw do
  get "all_records", to: "records#index"
  get "ta_assignments/new"
  get "ta_assignments/create"
  get "download_csv", to: "ta_assignments#download_csv", as: :download_csv_ta_assignments
  get "recommendations/new"
  resources :applicants
  resources :courses, only: [ :index ] do
    collection do
      post :import
      delete :clear
    end
  end

  get "sessions/new"
  get "sessions/create"
  get "sessions/destroy"
  get "home/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest


resources :assignments, only: [ :index ] do
    collection do
      post :import_csv   # POST /assignments/import_csv
      post :assign_ta
      get :assign_ta
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
  root "home#index" # home
  get "login", to: "sessions#login" # login form
  post "login", to: "sessions#create" # login
  get "/logout", to: "sessions#destroy", as: "logout" # logout

  # TA assignment
  post "ta_assignments/process_csvs", to: "ta_assignments#process_csvs", as: "process_csvs"
  get "ta_assignments/view_csv", to: "ta_assignments#view_csv", as: "view_csv"

  # TA reassignment
  post "ta_reassignments/process_csvs", to: "ta_reassignments#process_csvs", as: "reprocess_csvs"
  get "ta_reassignments/view_csv", to: "ta_reassignments#view_csv", as: "review_csv"
  get 'ta_reassignments/new', to: 'ta_reassignments#new', as: 'ta_reassignments_new'
  delete 'delete_all_csvs', to: 'ta_assignments#delete_all_csvs', as: 'delete_all_csvs'

  # Recommendation system
  get "recommendations/new", to: "recommendations#new", as: "recommendation_view"
  post "recommendations", to: "recommendations#create"
  # blacklist
  resources :blacklists, only: [ :index, :create, :destroy ]
  # export
  get "export_courses", to: "courses#export", as: :export_courses
  #withdrawer
  resources :withdrawal_requests, only: [:new, :create, :index]
  post 'export_final_csv', to: 'ta_assignments#export_final_csv', as: 'export_final_csv'

end
