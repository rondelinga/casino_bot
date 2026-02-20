Rails.application.routes.draw do
  post '/telegram/webhook', to: 'telegram_webhooks#create'
end
