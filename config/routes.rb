Rails.application.routes.draw do

	resources :hashtags
	resources :responses
  resources :twitter_bots
  get 'menu' => "pages#menu", as: :menu

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }, :path => '', :path_names => {:sign_in => 'login', :sign_out => 'logout'}
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root :to => 'pages#home'

end
