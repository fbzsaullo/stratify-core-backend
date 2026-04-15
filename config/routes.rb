# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :match_reports, only: [:index, :show] do
        resources :feedbacks, only: [:index]
      end

      get "health", to: proc { [200, {}, [{ status: "ok", version: "0.1.0-beta.6" }.to_json]] }
    end
  end
end
