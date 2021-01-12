require 'resque/server'
Rails.application.routes.draw do
  concern :commentable do
    resources :comments, only: %i[index create update destroy] do
      get :reply
      get :edit
    end
  end

  apipie
  namespace :admin do
    mount Resque::Server.new, at: "/resque"
  end
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_for :users, module: "ediofy/users"
  get 'about', to: "static_pages#about"
  get 'faq', to: "static_pages#faq"
  get 'privacy', to: "static_pages#privacy"


  namespace :ediofy, path: nil do
    post 'aws/s3_access_token', to: 'aws#s3_access_token'

    namespace :autocomplete do
      get :tags
      get :universities
      get :persons_and_companies
    end

    resources :playlists, only: [:index, :create, :show, :edit, :duplicate, :add, :update, :destroy]

    get  'duplicate_playlist/:id', to: 'playlists#duplicate', as: :duplicate_playlist
    patch 'copy_playlist/:id', to: 'playlists#copy', as: :copy_playlist
    get  'remove_playlist_content/:content_id', to: 'playlists#remove_content', as: :remove_playlist_content
    get  'set_playlist_img/:id', to: 'playlists#set_photo', as: :set_photo

    resources :conversations, concerns: :commentable do
      resources :images, only: [:destroy]
      post :add_images, on: :collection
      post :share_to_group, on: :member
      post :add_to_playlist, on: :member

      resources :votes, only: [] do
        collection do
          get :up
          get :down
          get :no
        end
      end

      resources :reports, only: [:create] do
        get 'report', on: :collection
      end
    end
    

    resources :groups do
      resources :media
      resources :links
      resources :conversations
      resources :questions
      resources :user_exam_questions

      resources :announcements do
        resources :votes, only: [] do
          collection do
            get :up
            get :down
            get :no
          end
        end
        resources :reports, only: [:create] do
          get 'report', on: :collection
        end
      end
      member do
        get :leave
        get :join
        get :report
        get :roles
        get 'remove_content/:content_id', to: 'groups#remove_content', as: :remove_content
        get 'accept_invite/:invite_id', to: 'groups#accept_invite', as: :accept_invite
        get 'cancel_invite/:user_id', to: 'groups#cancel_invite', as: :cancel_invite
      end
    end

    resources :links, except: [:index], concerns: :commentable do
      post :share_to_group, on: :member 
      post :update_cpd
      post :add_to_playlist, on: :member
      resources :images, only: [:destroy]
      collection do
        post :parse
        post :add_images
      end
      resources :votes, only: [] do
        collection do
          get :up
          get :down
          get :no
        end
      end
      resources :reports, only: [:create] do
        get 'report', on: :collection
      end
    end

    resources :universities, only: [:index, :show] do
      get :overview, to: 'universities#overview'
      get :users, to: 'universities#users'
      get :questions, to: 'universities#questions'
      get :media, to: 'universities#media'
      get :folders, to: 'universities#user_collections'
      get :join
      get :leave
    end


    resources :follows, only: [:index, :create, :destroy, :accept] do
      get 'reject/:user_id', to: 'follows#reject', as: :cancel_invite
      get 'accept/:user_id', to: 'follows#accept', as: :accept_invite
      get 'cancel/:user_id', to: 'follows#cancel', ac: :cancel_request
      post :request_follow, path: 'request'
  
    end

    get 'cancel_follow/:user_id', to: 'follows#cancel', ac: :cancel_request



  

  


    authenticated :user do
      root to: 'search#index', constraints: lambda { |request| request.params[:q].present? }
      root to: 'dashboard#index'
    end

    root to: 'home#show'
    post 'home/user_signin', controller: 'home', action: 'user_signin'
    post 'contact', to: 'enquiry#create'
    get :contact_thanks, :about, :disclaimer, :terms_and_conditions, :changelog, controller: 'static'

    resource :leaderboard, only: :show do
      get :this_week, :this_month, :all_time
    end

    concern :images, only: [:destroy]
    concern :votable do
      resources :votes, only, [:create]
    end

    concern :reportable do
      resources :reports, only, [:create]
    end

    resources :comments, only: [] do



      
      delete :destroy
        resources :votes, only: [] do
          
            collection do
              get :up
              get :down
              get :no
            end
          end
          resources :reports, only: [:create] do
            get 'report', on: :collection
          end




    end

    resources :announcements, only: [], concerns: :commentable do
      resources :votes, only: [] do
        collection do
          get :up
          get :down
          get :no
        end
      end
      resources :reports, only: [:create] do
        get 'report', on: :collection
      end
    end

    resources :interests, only:[:index]
    resources :histories, only:[:index]



    resources :media, concerns: :commentable do
      post :add_files, on: :collection
      post :update_cpd, on: :collection
      resources :reports, only: [:create] do
        get 'report', on: :collection
      end
      resources :votes, only: [] do
        collection do
          get :up
          get :down
          get :no
        end
      end
    end

    resources :media_files do
      resources :reports, only: [:create]
      resources :votes, only: [] do
        collection do
          get :up
          get :down
          get :no
        end
      end
      # post :upvote, :downvote, :novote, on: :member
      member do
        get :popup
        post :add_to_collection, path: 'add_to(/:media_collection_id)'
        post :remove_from_collection, path: 'remove_from(/:media_collection_id)'
        post :add_to_user_collection, path: 'add_to_story(/:user_collection_id)'
        post :remove_from_user_collection, path: 'remove_from_story(/:user_collection_id)'
        post :create_tag
        delete :destroy_tag
      end
    end

    resource :upload, only: :show
    resources :user_collections, path: :stories

    resources :media do
      member do
        get :reorder
        post :add_media
        post :share_to_group
        post :add_to_playlist
      end
    end

    resource :terms, path: 'terms', only: [:show, :create]
    resources :questions, concerns: :commentable do
      resources :images, only: [:destroy]
      resources :reports, only: [:create] do
        get 'report', on: :collection
      end
      post :add_images, on: :collection
      post :share_to_group, on: :member
      post :add_to_playlist, on: :member
      resources :votes, only: [] do
        collection do
          get :up
          get :down
          get :no
        end
      end
      get :add_media, path: 'add_media(/:media_id)', on: :collection
      member do
        get :answer, :duplicate
        post :upvote, :downvote, :novote
        post :add_to_user_collection, path: 'add_to_story(/:user_collection_id)'
        post :remove_from_user_collection, path: 'remove_from_story(/:user_collection_id)'
      end
    end

    authenticate :user do
      get :user, to: 'users#redirect_to_me', as: 'current_user'
    end

    namespace :users, as: 'user' do

      resources :ediofy_user_exams, path: 'exams', only: [:new, :create] do
        put :complete, on: :member
        get :complete, on: :member
        resources :user_exam_questions, path: 'questions', only: [:show, :update], controller: 'ediofy_user_exams/user_exam_questions' do
          put :answer
          post :share_to_group, on: :member
          post :add_to_playlist, on: :member
        end
      end

      get 'unauth/:action', controller: 'unauth', as: 'unauth'
      resource :setting, only: [:show, :update], path: 'settings', on: :collection do
        get 'change_password'
        put 'update_password'
        put 'update_profile'
        put 'change_ghost_mod'
        put 'change_privacy'
        put 'deactivate'
        put 'activate'
      end
      resources :notifications do
        collection do
          get :mentions
          get :settings
          put :settings
        end
        put :mark_as_read, on: :member
        put :mark_all_read, on: :collection
      end
      resources :invites, only: [:index, :create] do
        get :network_users, on: :collection
      end
    end
    resources :users, only: [ :show, :index ] do
      get :interests
      get :cpd_report, on: :member, as: :cpd_report
      post :update_cpd_comment, on: :collection
      get :pdf_cpd_report, on: :member
      post :update_cpd_times_range
      scope module: 'user' do
        resources :activities, only: 'index'
        resources :badges, only: 'index' do
          get :compare, on: :collection, path: 'compare/:other_user_id'
        end
        resources :points, only: 'index'
        resources :questions, only: 'index'
        resources :user_collections, path: :stories, only: 'index'
      end
    end

    resources :related, only: [:index]

    resource :dashboard, only: [], controller: 'dashboard', path: nil do
      get :content
      get :people
    end

    resource :search, only: [], controller: 'search' do
      get :content
      get :people
    end
  end
  get 'email_verification', :to => 'visitors#email_verification'
  get 'email_verification_succ', :to => 'visitors#email_verification_succ'
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth', :controllers => { passwords: "api/v1/users/passwords", :registrations => "api/v1/users/registrations",:confirmations =>'api/v1/users/confirmations', sessions: "api/v1/users/sessions"}
      namespace :users do
        resource :profile, only: [:update, :show]
        resource :setting, only: [:update, :show]
      end
      resources :questions, only: [:index, :show] do
        member do
          get :answer
          #post :upvote, :downvote, :novote
          post :report
        end
      end
      resources :ediofy_user_exams, path: 'exams', only: [:new, :create] do
        put :complete, on: :member
        get :complete, on: :member
        resources :user_exam_questions, path: 'questions', only: [:show, :update], controller: 'ediofy_user_exams/user_exam_questions'
      end
      resources :media, as: :media do
        member do
          post :upvote, :downvote, :novote
          get :view_more
          post :report
        end
      end
    end
  end
end
