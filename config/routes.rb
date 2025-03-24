# frozen_string_literal: true

Rails.application.routes.draw do

  # Root and Home
  root "home#index"
  get "home/index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up", to: "rails/health#show", as: :rails_health_check

  # Login
  get "login", to: "sessions#login" # login form
  post "login", to: "sessions#create" # login
  get "/logout", to: "sessions#destroy", as: "logout" # logout
  resources :sessions, only: [:new, :create, :destroy]

  # Records
  get "all_records", to: "records#index"

  # TA Assignments

  get "ta_assignments/new"
  get "ta_assignments/create"
  get "download_csv", to: "ta_assignments#download_csv", as: :download_csv_ta_assignments
<<<<<<< HEAD
  get "recommendations/new"

  root "home#index"

  get "/login", to: redirect("/auth/google_oauth2"), as: :login
  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/google_oauth2", to: redirect("/auth/google_oauth2/callback")
  get "/auth/failure", to: redirect("/")
  get "/logout", to: "sessions#destroy", as: "logout"

=======
>>>>>>> main
  resources :ta_assignments, only: [ :index, :edit, :update, :destroy ]

  

  # Applicants
  resources :applicants do
    collection do
      get :my_application
      get :search
    end
  end  


  resources :courses, only: [ :index, :update, :destroy, :create ] do
    collection do
      post :import
      delete :clear
      get :search
    end
  end

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

  # TA assignment
  post "ta_assignments/process_csvs", to: "ta_assignments#process_csvs", as: "process_csvs"
  get "ta_assignments/view_csv", to: "ta_assignments#view_csv", as: "view_csv"
  post "import_csv", to: "csv_imports#import", as: "import_csv"
  delete "delete_all_csvs", to: "ta_assignments#delete_all_csvs", as: "delete_all_csvs"


  # TA reassignment
  post "ta_reassignments/process_csvs", to: "ta_reassignments#process_csvs", as: "reprocess_csvs"
  get "ta_reassignments/view_csv", to: "ta_reassignments#view_csv", as: "review_csv"
  get "ta_reassignments/new", to: "ta_reassignments#new", as: "ta_reassignments_new"


  # Recommendation system
  resources :recommendations, only: [:new, :create, :index] do
    collection do
      get :export_csv
      delete :clear
    end
  end

  get 'courses/search', to: 'courses#search'
  get 'applicants/search', to: 'applicants#search'

  get "recommendations/new", to: "recommendations#new", as: "recommendation_view"
  post "recommendations", to: "recommendations#create"

  # blacklist
  resources :blacklists, only: [ :index, :create, :destroy ]

  # export
  get "export_courses", to: "courses#export", as: :export_courses

  # withdrawer
  resources :withdrawal_requests, only: [ :new, :create, :index ]
  post "export_final_csv", to: "ta_assignments#export_final_csv", as: "export_final_csv"
end
