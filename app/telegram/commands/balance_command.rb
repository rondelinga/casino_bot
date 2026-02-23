module Telegram
  module Commands
    class BalanceCommand < BaseCommand
      def call
        @responder.send("💰 Твой баланс: #{@user.balance} токенов")
      end
    end
  end
end