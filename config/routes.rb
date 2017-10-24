Adela::Application.routes.draw do
  localized do
    devise_for :users

    as :user do
      get 'users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
      patch 'users/:id' => 'devise/registrations#update', as: 'user_registration'
    end

    get '/:slug/catalogo' => 'organizations#catalog', as: 'organization_catalog'
    get '/:slug/inventario' => 'organizations#inventory', as: 'organization_inventory'

    root to: 'home#index'

    resources :organizations, only: [:show, :update] do
      get 'profile', on: :member
      get 'search', on: :collection

      resources :documents, controller: 'organizations/documents', only: [:index] do
        put 'update', on: :collection, as: 'update'
      end

      resources :catalogs, only: [:index], shallow: true do
        get 'check', on: :collection
        put 'publish', on: :member

        resources :datasets, shallow: true do
          resources :distributions
        end
      end
    end
  end

  resources :catalog_versions, path: 'catalog/versions', only: [:index, :show]

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      get '/catalogs' => 'organizations#catalogs'
      get '/organizations' => 'organizations#organizations'
      get '/gov_types' => 'organizations#gov_types'

      resources :datasets, only: [] do
        get 'contact_point', on: :member
      end

      resources :distributions, only: [:show]

      resources :organizations, only: [:show] do
        get 'inventory', on: :member
        get 'documents', on: :member
        collection do
          get 'catalogs'
          get 'organizations'
        end
      end
      resources :sectors, only: [:index]
    end
  end

  namespace :admin do
    get '/', to: 'base#index', as: 'root'

    get 'import_users', to: 'users#import'
    post 'create_users', to: 'users#create_users'
    post 'stop_acting', to: 'users#stop_acting'
    resources :users, except: :show do
      member do
        put 'grant_admin_role'
        put 'remove_admin_role'
        get 'acting_as'
        get 'edit_password'
        put 'update_password'
      end
    end

    resources :organizations, except: [:show, :destroy] do
      get :edit_multiple, on: :collection
      put :update_multiple, on: :collection
    end
  end

  namespace :inventories do
    resources :datasets do
      get 'confirm_destroy', on: :member
      resources :distributions do
        get 'confirm_destroy', on: :member
      end
    end
  end
end
