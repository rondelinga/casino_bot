module Telegram
  class BotResponder
    def initialize(chat_id)
      @chat_id = chat_id
    end

    def send(text, parse_mode: nil)
      options = { chat_id: @chat_id, text: text }
      options[:parse_mode] = parse_mode if parse_mode
      bot.api.send_message(**options)
    end

    private

    def bot
      @bot ||= ::Telegram::Bot::Client.new(ENV['TELEGRAM_BOT_TOKEN'])
    end
  end
end
