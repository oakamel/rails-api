Rails.application.routes.draw do
  resources :applications do
    resources :chats do
      resources :messages
    end
  end
  get '/messages/search/', to: 'messages#search'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
