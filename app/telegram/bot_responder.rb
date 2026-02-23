class BotResponder
  def initialize(chat_id, reply_to: nil)
    @chat_id  = chat_id
    @reply_to = reply_to
  end

  def send(text, parse_mode: nil)
    options = { chat_id: @chat_id, text: text }
    options[:parse_mode]          = parse_mode if parse_mode
    options[:reply_to_message_id] = @reply_to  if @reply_to
    bot.api.send_message(**options)
  end

  def send_with_keyboard(text, buttons:, parse_mode: nil)
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(
      inline_keyboard: buttons
    )
    options = { chat_id: @chat_id, text: text, reply_markup: markup }
    options[:parse_mode] = parse_mode if parse_mode
    bot.api.send_message(**options)
  end

  def answer_callback(callback_query_id, text: nil)
    bot.api.answer_callback_query(
      callback_query_id: callback_query_id,
      text: text
    )
  end

  private

  def bot
    @bot ||= ::Telegram::Bot::Client.new(ENV['TELEGRAM_BOT_TOKEN'])
  end
end
