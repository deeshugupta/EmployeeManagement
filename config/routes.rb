EmployeeManagement::Application.routes.draw do

  get "holidays/index"

  get "holidays/new"

  get "holidays/edit"

  devise_for :users, skip: :registrations
  devise_scope :user do
    resource :registration, only: [:edit, :update], path: 'users', controller: 'devise/registrations', as: :user_registration
  end

  root :to => 'dashboard#index'
  resources :roles
  resources :attendances do
    collection do
      get :my_requests
      get :apply_leave
      get :pending_approvals
      get :search_pending_approvals
      get :available_leaves
      get :team_leaves
    end
  end
  post "dashboard/search" => "dashboard#search", :as => :dashboard_search
  resources :dashboard do
    collection do
      get :my_team
      get :approve
      get :entire_team
    end
  end

  resources :users

  resources :holidays

  match ':controller(/:action(:/id))'

  get 'search/search_emails' => 'search#search_emails'
  get 'search/search_name' => 'search#search_name'
  get 'search/search_manager_name' => 'search#search_manager_name'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.

end
