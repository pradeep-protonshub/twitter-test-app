Rails.application.routes.draw do
  devise_for :users,
             path: '',
             path_names: {
                 sign_in: 'api/v1/login',
                 sign_out: 'api/v1/logout',
                 registration: 'api/v1/signup'
             },
             controllers: {
                 sessions: 'api/v1/users/sessions',
                 registrations: 'api/v1/users/registrations'
             }

  namespace :api , defaults: { format: 'json' } do
    namespace :v1 do
      
      resources :users, only: [:update, :show] do
        collection do
          post :reset_home_location
        end
      end

      
    resources :tweets, only:[:create,:destroy]
    get 'follow', to: 'users#follow'
    get 'unfollow', to: 'users#unfollow'
    get 'followers_tweets', to: 'users#followers_tweets'
    get 'user_profile', to: 'users#user_profile'
  end
  end
end