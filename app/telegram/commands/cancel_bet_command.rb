module Commands
    class CancelBetCommand < BaseCommand
      def initialize(message, user, responder, predict_id)
        super(message, user, responder)
        @predict_id = predict_id.to_i
      end

      def call
        return no_access unless @user.admin? || @user.creator?

        predict = Bet.where(status: [:open, :closed]).find_by(id: @predict_id)
        return @responder.send("❌ Предсказание не найдена") unless predict

        predict.cancel!
        @responder.send("❌ Предсказание отменена, токены возвращены")
      end
    end
end
