require 'telegram/bot'

class TelegramWebhooksController < ApplicationController
  def create
    update = Telegram::Bot::Types::Update.new(params.to_unsafe_h)

    if update.callback_query
      CommandRouter.new(callback_query: update.callback_query).dispatch
    elsif update.message&.text
      CommandRouter.new(message: update.message).dispatch
    end

    head :ok
  end
end
