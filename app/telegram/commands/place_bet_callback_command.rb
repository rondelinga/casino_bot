module Commands
  class PlaceBetCallbackCommand < BaseCommand
    def initialize(callback_query, user, responder, predict_id, position, amount)
      @callback_query = callback_query
      @user           = user
      @responder      = responder
      @predict_id         = predict_id.to_i
      @position       = position.to_i
      @amount         = amount.to_i
    end

    def call
      predict = Bet.open.find_by(id: @predict_id)
      return @responder.answer_callback(@callback_query.id, text: "❌ Предсказание закрыта") unless predict

      outcome = predict.bet_outcomes.find_by(position: @position)
      return @responder.answer_callback(@callback_query.id, text: "❌ Исход не найден") unless outcome

      if predict.bet_entries.exists?(user: @user)
        return @responder.answer_callback(@callback_query.id, text: "❌ Ты уже сделал предсказание")
      end

      if @amount <= 0 || @user.balance < @amount
        return @responder.answer_callback(@callback_query.id, text: "❌ Недостаточно токенов (баланс: #{@user.balance})")
      end

      @user.update!(balance: @user.balance - @amount)
      predict.bet_entries.create!(user: @user, bet_outcome: outcome, amount: @amount)

      @responder.answer_callback(@callback_query.id, text: "✅ Предсказание принята!")
      @responder.send(
        "✅ Предсказание принята!\n#{@amount} токенов на «#{outcome.title}»\n\n#{predict.summary}",
        parse_mode: 'Markdown'
      )
    end
  end
end
