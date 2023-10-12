Rails.application.routes.draw do
  scope :api, constraints: { format: 'json' }, defaults: { format: 'json' } do 
    scope :v1 do
      resources :data, only: :index
    end
  end

  root to: "data#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
