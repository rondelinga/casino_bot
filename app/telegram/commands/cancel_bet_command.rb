module Commands
    class CancelBetCommand < BaseCommand
      def initialize(message, user, responder, bet_id)
        super(message, user, responder)
        @bet_id = bet_id.to_i
      end

      def call
        return no_access unless @user.admin? || @user.creator?

        bet = Bet.where(status: [:open, :closed]).find_by(id: @bet_id)
        return @responder.send("❌ Ставка не найдена") unless bet

        bet.cancel!
        @responder.send("❌ Ставка отменена, токены возвращены")
      end
    end
end
