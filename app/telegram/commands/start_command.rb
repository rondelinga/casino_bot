module Telegram
  module Commands
    class StartCommand < BaseCommand
      def call
        @responder.send(
          "🎰 Добро пожаловать в казино, #{@message.from.first_name}!\n\n" \
          "Твой баланс: #{@user.balance} токенов\n\n" \
          "/spin — крутить слоты (10 токенов)\n/balance — проверить баланс"
        )
      end
    end
  end
end
