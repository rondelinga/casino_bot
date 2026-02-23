require 'telegram/bot'

class TelegramWebhooksController < ApplicationController
  def create
    update = Telegram::Bot::Types::Update.new(params.to_unsafe_h)
    message = update.message

    return head :ok unless message&.text

    user = User.find_or_create_by_telegram(message.from.id)
    user.update(username: message.from.username)

    case message.text
    when '/start'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "🎰 Добро пожаловать в казино, #{message.from.first_name}!\n\nТвой баланс: #{user.balance} токенов\n\n/spin — крутить слоты (10 токенов)\n/balance — проверить баланс"
      )

    when '/balance'
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "💰 Твой баланс: #{user.balance} токенов"
      )

    when '/spin'
      machine = SlotMachine.new(user)
      result = machine.spin!
    
      if result[:error] == :no_tokens
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "😢 Недостаточно токенов!\nПриходи завтра за новыми #{User::DAILY_TOKENS} токенами."
        )
      else
        grid_text = machine.display_grid(result[:grid])
    
        if result[:winnings] > 0
          lines_text = result[:winning_lines].join("\n")
          text = "🎰 Крутим...\n\n#{grid_text}\n\n#{lines_text}\n\n💰 Итого: +#{result[:winnings]} токенов\nБаланс: #{result[:balance]}"
        else
          text = "🎰 Крутим...\n\n#{grid_text}\n\n😔 Нет выигрышных комбинаций\nБаланс: #{result[:balance]}"
        end

        bot.api.send_message(chat_id: message.chat.id, text: text)
      end

    when '/users'
      return no_access(message) unless user.admin?

      list = User.all.map do |u|
        "#{u.display_name} — #{role_label(u)} — #{u.balance} токенов"
      end.join("\n")
      bot.api.send_message(chat_id: message.chat.id, text: "👥 Пользователи:\n\n#{list}")

    when /^\/set_role (\d+) (user|creator|admin)$/
      return no_access(message) unless user.admin?

      target_telegram_id = $1.to_i
      new_role = $2
      target = User.find_by(telegram_id: target_telegram_id)

      if target
        target.update!(role: new_role)
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "✅ Пользователь #{target_telegram_id} теперь #{role_label(target)}"
        )
      else
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "❌ Пользователь #{target_telegram_id} не найден"
        )
      end
    end

    head :ok
  end

  private

  def bot
    @bot ||= Telegram::Bot::Client.new(ENV['TELEGRAM_BOT_TOKEN'])
  end

  def no_access(message)
    bot.api.send_message(chat_id: message.chat.id, text: "⛔ Нет доступа.")
    head :ok
  end

  def role_label(user)
    { 'user' => '👤 Игрок', 'creator' => '🎨 Креатор', 'admin' => '👑 Админ' }[user.role]
  end
end
