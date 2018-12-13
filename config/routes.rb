Rails.application.routes.draw do

  mount ActionCable.server => '/cable'

  devise_for :users

  authenticated :user do
    root "home#index"
  end

  unauthenticated :user do
    root "landingpage#lp"
  end

  resources :conversations, only: [:create] do
    member do
      post :close
    end

    resources :messages, only: [:create]
  end

    resources :chatrooms do
      resource :chatrooms_users
      resources :usersmessages
    end

  get "messages",                       to: "conversations#show"
  get "conversation_user",              to: "conversations#conversation_user"

  resources :games
  post "search_games",                  to: "games#search_games"
  get "advanced_search_games",          to: "games#advanced_search_games"
  post "create_comment",                to: "games#create_comment"
  post "update_comment",                to: "games#update_comment"
  post "destroy_comment",               to: "games#destroy_comment"

  get "index",                          to: "home#index"
  get "profile",                        to: "home#profile"
  get "favoris",                        to: "home#favoris"
  get 'add_to_favorites',               to: "home#add_to_favorites"
  get 'remove_from_favorites',          to: "home#remove_from_favorites"

  resources :gamesession
  post "search_sessions",               to: "gamesession#search_sessions"
  get "joingame",                       to: "gamesession#joingame"
  get "leavegame",                      to: "gamesession#leavegame"
  get "acceptrequest",                  to: "gamesession#acceptrequest"
  get "denyrequest",                    to: "gamesession#denyrequest"
  get "removerequest",                  to: "gamesession#removerequest"
  get "mysessions",                     to: "home#mysessions"
  get "player/:id",                     to: "home#player"

  get "list_users",                     to:"home#list_users"

  get "webmaster",                      to: "handleuser#webmaster"
  post "webmaster",                     to: "handleuser#scrapping"
  post "scrapping",                     to: "handleuser#scrapping"
  get "admin",                          to: "handleuser#admin"
  post "/superpost",                    to: "handleuser#superpost"
  get "emailuser/:id",                  to: "handleuser#emailuser"
  post "sendemail",                     to: "handleuser#sendemail"
  get "/contact_us",                    to: "handleuser#contact_us"
  post "mail_us",                       to: "handleuser#mail_us"
end
