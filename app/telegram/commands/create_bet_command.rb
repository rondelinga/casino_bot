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
        title = parts[0]
        rest  = parts[1..]

        if rest.length < 2
          return @responder.send(
            "❌ Формат: /create_bet Название|Исход 1|Исход 2\n" \
            "С коэффициентами: /create_bet Название|Исход 1|Исход 2|2.3|4\n" \
            "Без коэффициентов — они рассчитаются динамически по ставкам"
          )
        end

        half      = rest.length / 2
        maybe_odds = rest[half..].map { |o| Float(o) rescue nil }

        if rest.length.even? && maybe_odds.none?(&:nil?) && maybe_odds.all? { |o| o > 0 }
          titles   = rest[0...half]
          odds     = maybe_odds
        else
          titles   = rest
          odds     = nil
        end

        if odds && odds.any? { |o| o <= 0 }
          return @responder.send("❌ Коэффициенты должны быть числами больше 0\nПример: 1.5, 2.3, 4")
        end

        bet = BetCreator.new(@user, title: title, outcomes: titles, odds: odds).create!
        @responder.send("✅ Ставка создана! ID: #{bet.id}\n\n#{bet.summary}", parse_mode: 'Markdown')
      end
    end
  end
end
