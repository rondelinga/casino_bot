Rails.application.routes.draw do
  get '/up', to: proc { [200, {}, ['ok']] }
  post '/telegram/webhook', to: 'telegram_webhooks#create'
end
