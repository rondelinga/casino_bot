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

    when '/bets'
      bets = Bet.open
      if bets.empty?
        bot.api.send_message(chat_id: message.chat.id, text: "🎲 Нет активных ставок")
      else
        text = bets.map { |b| "#{b.id}. #{b.summary}" }.join("\n\n")
        bot.api.send_message(chat_id: message.chat.id, text: text, parse_mode: 'Markdown')
      end

    when /^\/bet (\d+) (\d+) (\d+)$/
      bet_id, position, amount = $1.to_i, $2.to_i, $3.to_i

      bet = Bet.open.find_by(id: bet_id)
      unless bet
        bot.api.send_message(chat_id: message.chat.id, text: "❌ Ставка не найдена или уже закрыта")
        return head :ok
      end

      outcome = bet.bet_outcomes.find_by(position: position)
      unless outcome
        bot.api.send_message(chat_id: message.chat.id, text: "❌ Исход #{position} не существует")
        return head :ok
      end

      if bet.bet_entries.exists?(user: user)
        bot.api.send_message(chat_id: message.chat.id, text: "❌ Ты уже сделал ставку на это событие")
        return head :ok
      end

      if amount <= 0 || user.balance < amount
        bot.api.send_message(chat_id: message.chat.id, text: "❌ Недостаточно токенов")
        return head :ok
      end

      user.update!(balance: user.balance - amount)
      bet.bet_entries.create!(user: user, bet_outcome: outcome, amount: amount)

      bot.api.send_message(
        chat_id: message.chat.id,
        text: "✅ Ставка принята!\n#{amount} токенов на «#{outcome.title}»\n\n#{bet.summary}",
        parse_mode: 'Markdown'
      )

    when /^\/create_bet (.+)$/
      return no_access(message) unless user.admin? || user.creator?

      parts = $1.split('|').map(&:strip)
      if parts.length < 3
        bot.api.send_message(
          chat_id: message.chat.id,
          text: "❌ Формат: /create_bet Название|Исход 1|Исход 2\nили /create_bet Название|Исход 1|Исход 2|Исход 3"
        )
        return head :ok
      end

      title = parts[0]
      outcomes = parts[1..]
      bet = BetCreator.new(user, title: title, outcomes: outcomes).create!

      bot.api.send_message(
        chat_id: message.chat.id,
        text: "✅ Ставка создана! ID: #{bet.id}\n\n#{bet.summary}",
        parse_mode: 'Markdown'
      )

    when /^\/close_bet (\d+)$/
      return no_access(message) unless user.admin? || user.creator?

      bet = Bet.open.find_by(id: $1.to_i)
      unless bet
        bot.api.send_message(chat_id: message.chat.id, text: "❌ Ставка не найдена")
        return head :ok
      end

      bet.update!(status: :closed)
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "🔒 Приём ставок закрыт\n\n#{bet.summary}",
        parse_mode: 'Markdown'
      )

    when /^\/resolve_bet (\d+) (\d+)$/
      return no_access(message) unless user.admin? || user.creator?

      bet = Bet.where(status: [:open, :closed]).find_by(id: $1.to_i)
      unless bet
        bot.api.send_message(chat_id: message.chat.id, text: "❌ Ставка не найдена")
        return head :ok
      end

      outcome = bet.bet_outcomes.find_by(position: $2.to_i)
      unless outcome
        bot.api.send_message(chat_id: message.chat.id, text: "❌ Исход не найден")
        return head :ok
      end

      bet.resolve!(outcome.id)
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "🏆 Победил исход «#{outcome.title}»!\nВыигрыши начислены."
      )

    when /^\/cancel_bet (\d+)$/
      return no_access(message) unless user.admin? || user.creator?

      bet = Bet.where(status: [:open, :closed]).find_by(id: $1.to_i)
      unless bet
        bot.api.send_message(chat_id: message.chat.id, text: "❌ Ставка не найдена")
        return head :ok
      end

      bet.cancel!
      bot.api.send_message(chat_id: message.chat.id, text: "❌ Ставка отменена, токены возвращены")

    when '/users'
      return no_access(message) unless user.admin?

      list = User.all.map do |u|
        "#{u.display_name} — #{role_label(u)} — #{u.balance} токенов"
      end.join("\n")
      bot.api.send_message(chat_id: message.chat.id, text: "👥 Пользователи:\n\n#{list}")

    when /^\/set_role (\d+) (user|creator|admin)$/
      return no_access(message) unless user.admin?

      target = User.find_by(telegram_id: $1.to_i)
      unless target
        bot.api.send_message(chat_id: message.chat.id, text: "❌ Пользователь не найден")
        return head :ok
      end

      target.update!(role: $2)
      bot.api.send_message(
        chat_id: message.chat.id,
        text: "✅ Пользователь #{target.telegram_id} теперь #{role_label(target)}"
      )
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
