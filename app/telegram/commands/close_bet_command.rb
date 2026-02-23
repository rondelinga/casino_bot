module Commands
    class CloseBetCommand < BaseCommand
      def initialize(message, user, responder, bet_id)
        super(message, user, responder)
        @bet_id = bet_id.to_i
      end

      def call
        return no_access unless @user.admin? || @user.creator?

        bet = Bet.open.find_by(id: @bet_id)
        return @responder.send("❌ Ставка не найдена") unless bet

        bet.update!(status: :closed)
        @responder.send("🔒 Приём ставок закрыт\n\n#{bet.summary}", parse_mode: 'Markdown')
      end
    end
end
