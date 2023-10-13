Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
        #todo: non local
      origins 'localhost:3001'
      resource '*', headers: :any, methods: [:get, :post, :options]
    end
  end
  