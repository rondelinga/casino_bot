module Commands
    class CloseBetCommand < BaseCommand
      def initialize(message, user, responder, predict_id)
        super(message, user, responder)
        @predict_id = predict_id.to_i
      end

      def call
        return no_access unless @user.admin? || @user.creator?

        predict = Bet.open.find_by(id: @predict_id)
        return @responder.send("❌ Предсказание не найдена") unless predict

        predict.update!(status: :closed)
        @responder.send("🔒 Приём ставок закрыт\n\n#{predict.summary}", parse_mode: 'Markdown')
      end
    end
end
