module Commands
  class SelectBetOutcomeCommand < BaseCommand
    def initialize(callback_query, user, responder, predict_id, position)
      @callback_query = callback_query
      @user           = user
      @responder      = responder
      @predict_id         = predict_id.to_i
      @position       = position.to_i
    end

    def call
      predict = Bet.open.find_by(id: @predict_id)
      unless predict
        @responder.answer_callback(@callback_query.id, text: "❌ Предсказание уже закрыта")
        return
      end

      outcome = predict.bet_outcomes.find_by(position: @position)
      unless outcome
        @responder.answer_callback(@callback_query.id, text: "❌ Исход не найден")
        return
      end

      if predict.bet_entries.exists?(user: @user)
        @responder.answer_callback(@callback_query.id, text: "❌ Ты уже сделал предсказание")
        return
      end

      @responder.answer_callback(@callback_query.id)

      amounts = [10, 25, 50, 100, 250]
      buttons = [
        amounts.map do |amount|
          {
            text: "#{amount} 🪙",
            callback_data: "place:#{@predict_id}:#{@position}:#{amount}"
          }
        end
      ]

      @responder.send_with_keyboard(
        "💰 Предсказание на *#{outcome.title}*\nВыбери сумму или введи /predict #{@predict_id} #{@position} <сумма>",
        buttons: buttons,
        parse_mode: 'Markdown'
      )
    end
  end
end
