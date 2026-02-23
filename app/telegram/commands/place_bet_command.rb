module Commands
    class PlaceBetCommand < BaseCommand
      def initialize(message, user, responder, predict_id, position, amount)
        super(message, user, responder)
        @predict_id   = predict_id.to_i
        @position = position.to_i
        @amount   = amount.to_i
      end

      def call
        predict = Bet.open.find_by(id: @predict_id)
        return @responder.send("❌ Предсказание не найдена или уже закрыта") unless predict

        outcome = predict.bet_outcomes.find_by(position: @position)
        return @responder.send("❌ Исход #{@position} не существует") unless outcome

        return @responder.send("❌ Ты уже сделал предсказание на это событие") if predict.bet_entries.exists?(user: @user)
        return @responder.send("❌ Недостаточно токенов") if @amount <= 0 || @user.balance < @amount

        @user.update!(balance: @user.balance - @amount)
        predict.bet_entries.create!(user: @user, bet_outcome: outcome, amount: @amount)

        @responder.send(
          "✅ Предсказание принята!\n#{@amount} токенов на «#{outcome.title}»\n\n#{predict.summary}",
          parse_mode: 'Markdown'
        )
      end
    end
end
