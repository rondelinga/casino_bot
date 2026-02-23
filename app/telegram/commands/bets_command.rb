module Commands
  class BetsCommand < BaseCommand
    def call
      predict = Bet.open
      if predict.empty?
        return @responder.send("🎲 Нет активных ставок")
      end

      predict.each do |predict|
        buttons = predict.bet_outcomes.map do |outcome|
          [{ text: outcome.title, callback_data: "predict:#{predict.id}:#{outcome.position}" }]
        end

        @responder.send_with_keyboard(
          "📊 *#{predict.title}*\n#{predict.summary}",
          buttons: buttons,
          parse_mode: 'Markdown'
        )
      end
    end
  end
end
