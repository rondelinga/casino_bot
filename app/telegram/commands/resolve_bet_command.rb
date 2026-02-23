module Commands
    class ResolveBetCommand < BaseCommand
      def initialize(message, user, responder, bet_id, position)
        super(message, user, responder)
        @bet_id   = bet_id.to_i
        @position = position.to_i
      end

      def call
        return no_access unless @user.admin? || @user.creator?

        bet = Bet.where(status: [:open, :closed]).find_by(id: @bet_id)
        return @responder.send("❌ Ставка не найдена") unless bet

        outcome = bet.bet_outcomes.find_by(position: @position)
        return @responder.send("❌ Исход не найден") unless outcome

        bet.resolve!(outcome.id)
        @responder.send("🏆 Победил исход «#{outcome.title}»!\nВыигрыши начислены.")
      end
    end
end
