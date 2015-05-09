Rails.application.routes.draw do
  resources :comments, only: [:create, :destroy]

  resources :albums

  resources :friendships, only: [:create] do
    post 'accept', on: :member, to: 'friendships#accept'
    delete 'reject', on: :member, to: 'friendships#destroy'
  end



  resources :images, only: [:show, :index, :new, :create, :destroy] do
    post 'set_visibility', on: :member, to: 'images#set_visibility'
    post 'set_album', on: :member, to: 'images#set_album'
  end

  resources :users do
    post 'set_role', on: :member, to: 'users#set_role'
  end

  resource :sessions, only: [:new, :create, :delete]


  delete 'logout', to: 'sessions#destroy'
  get 'root', to: 'images#index'
  get '/', to: 'images#index'

  # ugly hack to make certain tests work...
  get 's3images/medium/missing.png', to: 'images#index'

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
