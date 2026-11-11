Rails.application.routes.draw do
  root "public_portal/home#show"
  get "calendario", to: "public_portal/calendar#show", as: :public_calendar
  get "robots.txt", as: :robots, to: "public_portal/seo#robots", defaults: { format: :text }
  get "sitemap.xml", as: :sitemap, to: "public_portal/seo#sitemap", defaults: { format: :xml }
  get "eventos/:id/fotos/:photo_id/preview", to: "public_portal/photos#local_preview", as: :local_public_event_photo_preview, constraints: { id: /[a-zA-Z0-9_-]+/, photo_id: /[0-9a-fA-F-]{36}/ }
  get "eventos/:id/fotos", to: "public_portal/photos#show", as: :public_event_photos, constraints: { id: /[a-zA-Z0-9_-]+/ }
  get "fotos", to: "public_portal/photos#index", as: :public_photos
  get "eventos/:id/resultados", to: "public_portal/results#show", as: :public_event_results, constraints: { id: /[a-zA-Z0-9_-]+/ }
  get "resultados", to: "public_portal/results#index", as: :public_results
  get "eventos/:id", to: "public_portal/events#show", as: :public_event, constraints: { id: /[a-zA-Z0-9_-]+/ }
  get "eventos", to: "public_portal/events#index", as: :public_events

  get "up" => "rails/health#show", as: :rails_health_check
end
