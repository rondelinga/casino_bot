module Telegram
  module Commands
    class PlaceBetCommand < BaseCommand
      def initialize(message, user, responder, bet_id, position, amount)
        super(message, user, responder)
        @bet_id   = bet_id.to_i
        @position = position.to_i
        @amount   = amount.to_i
      end

      def call
        bet = Bet.open.find_by(id: @bet_id)
        return @responder.send("❌ Ставка не найдена или уже закрыта") unless bet

        outcome = bet.bet_outcomes.find_by(position: @position)
        return @responder.send("❌ Исход #{@position} не существует") unless outcome

        return @responder.send("❌ Ты уже сделал ставку на это событие") if bet.bet_entries.exists?(user: @user)
        return @responder.send("❌ Недостаточно токенов") if @amount <= 0 || @user.balance < @amount

        @user.update!(balance: @user.balance - @amount)
        bet.bet_entries.create!(user: @user, bet_outcome: outcome, amount: @amount)

        @responder.send(
          "✅ Ставка принята!\n#{@amount} токенов на «#{outcome.title}»\n\n#{bet.summary}",
          parse_mode: 'Markdown'
        )
      end
    end
  end
end
