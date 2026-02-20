require 'telegram/bot'

class TelegramWebhooksController < ApplicationController
  def create
    update = Telegram::Bot::Types::Update.new(params.to_unsafe_h)
    message = update.message

    return head :ok unless message&.text

    if message.text.start_with?('/ping')
      username = message.from.username ? "@#{message.from.username}" : message.from.first_name

      bot.api.send_message(
        chat_id: message.chat.id,
        text: username
      )
    end

    head :ok
  end

  private

  def bot
    @bot ||= Telegram::Bot::Client.new(
      Rails.application.credentials.telegram[:bot_token]
    )
  end
end
