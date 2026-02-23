module Telegram
  module Commands
    class CreateBetCommand < BaseCommand
      def initialize(message, user, responder, raw_input)
        super(message, user, responder)
        @raw_input = raw_input
      end

      def call
        return no_access unless @user.admin? || @user.creator?

        parts = @raw_input.split('|').map(&:strip)
        if parts.length < 3
          return @responder.send(
            "❌ Формат: /create_bet Название|Исход 1|Исход 2\n" \
            "или /create_bet Название|Исход 1|Исход 2|Исход 3"
          )
        end

        bet = BetCreator.new(@user, title: parts[0], outcomes: parts[1..]).create!
        @responder.send("✅ Ставка создана! ID: #{bet.id}\n\n#{bet.summary}", parse_mode: 'Markdown')
      end
    end
  end
end
