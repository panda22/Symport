Rails.application.routes.draw do

  root "index#index"

  post '/session/create', to: 'session#create'
  post '/session/activity', to: 'session#activity'
  get '/session/valid', to: 'session#valid'
  delete '/session', to: 'session#destroy'

  post "/user", to: "user#create"
  get "/user", to: "user#show"
  put "/user", to: "user#update"

  put "/password_resets", to: "password_resets#update"

  resources :projects, only: ['index', 'create', 'show', 'update', 'destroy'], constraints: { format: :json } do
    member do
      post 'create_structure'
      post 'codebook'
      post 'query_details'
      get "known_subjects"
      put "rename_subject_id"
      put "errors_for_question"
      put "import_responses"
      put "import_sample_data_1"
      put "import_sample_data_2"
      put "update_demo_progress"
    end
    resources :team_members, only: ['index', 'create', 'destroy', 'update']
  end

  get "/projects/can_view_phi/:id", to: "projects#can_view_phi"



  resources :form_structures, only: ['index', 'show', 'update', 'destroy'], constraints: { format: :json } do
    member do
      get 'response_query'
      get 'existing_subjects'
      #get 'error_query/:subject_id', to: "form_structures#get_errors"
    end
    resources :form_questions, only: ['create', 'show', 'update', 'destroy']
    resources :form_responses, only: ['update', 'show', 'destroy']
  end
  post "/form_structures/:form_structure_id/form_responses/get_by_subject_and_instance", to: "form_responses#get_by_subject_and_instance"
  put "/form_structures/:form_structure_id/form_responses", to: "form_responses#update"
  post "/form_structures/:id/export", to: "form_structures#export"
  post "/form_structures/set_response_secondary_ids/:id", to: "form_structures#set_response_secondary_ids"
  get "/form_structures/get_max_instances/:id", to: "form_structures#get_max_instances"
  get "/form_responses/known_subjects_by_form/:form_id", to: "form_responses#known_subjects_by_form"

  post "/form_responses/:id/rename_instance", to: "form_responses#rename_instance"
  post "form_responses/destroy_instances_for_subject/", to: "form_responses#destroy_instances_for_subject"
  post "form_responses/create_new", to: "form_responses#create_new"
  get "form_responses/find_by_id/:id", to: "form_responses#find_by_id"

  post "/pending_user/resend", to: "pending_user#resend"
  get "pending_user/sign_in/:user_id/:id", to: "pending_user#sign_in"
  post "pending_user/get_from_team_member/", to: "pending_user#get_from_team_member"
  post "pending_user/validate", to: "pending_user#validate"
  post "pending_user/create_as_team_member/:project_id", to: "pending_user#create_as_team_member"

  get "/project_view_data/:id", to: "project_view_data#get_view_data"
  get "/project_view_data/query/:id", to: "project_view_data#get_forms_and_questions"
  post "/project_view_data/query", to: "project_view_data#get_query_data"
  post "/project_view_data/download_results", to: "project_view_data#download_results"
  
  resources :password_resets, only: ['index', 'create', 'show', 'update', 'destroy'], constraints: { format: :json }

  resources :queries, only: ['create', 'show', 'destroy', 'update']
  get "/queries/get_all_queries/:project_id/:order", to: "queries#get_all_queries"
  post "/queries/validate/", to: "queries#validate"
  post "/queries/edit_permissions", to: "queries#edit_permissions"

  get "/form_data/get_initial_form_data/:form_id", to: "form_data#get_initial_form_data"
  get "/form_data/get_remaining_form_data/:form_id", to: "form_data#get_remaining_form_data"

  post "/form_data_event/update_question", to: "form_data_event#update_question"
  post "/form_data_event/save_answers_for_question", to: "form_data_event#save_answers_for_question"
  get "/form_data_event/get_question_errors/:question_id", to: "form_data_event#get_question_errors"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
