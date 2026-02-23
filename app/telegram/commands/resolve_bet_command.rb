module Commands
    class ResolveBetCommand < BaseCommand
      def initialize(message, user, responder, predict_id, position)
        super(message, user, responder)
        @predict_id   = predict_id.to_i
        @position = position.to_i
      end

      def call
        return no_access unless @user.admin? || @user.creator?

        predict = Bet.where(status: [:open, :closed]).find_by(id: @predict_id)
        return @responder.send("❌ Предсказание не найдена") unless predict

        outcome = predict.bet_outcomes.find_by(position: @position)
        return @responder.send("❌ Исход не найден") unless outcome

        predict.resolve!(outcome.id)
        @responder.send("🏆 Победил исход «#{outcome.title}»!\nВыигрыши начислены.")
      end
    end
end
