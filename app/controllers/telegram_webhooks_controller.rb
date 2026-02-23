require 'telegram/bot'

class TelegramWebhooksController < ApplicationController
  def create
    update = Telegram::Bot::Types::Update.new(params.to_unsafe_h)
    message = update.message
    return head :ok unless message&.text

    CommandRouter.new(message).dispatch
    head :ok
  end
end
