module Telegram
  module Commands
    class BetsCommand < BaseCommand
      def call
        bets = Bet.open
        if bets.empty?
          @responder.send("🎲 Нет активных ставок")
        else
          text = bets.map { |b| "#{b.id}. #{b.summary}" }.join("\n\n")
          @responder.send(text, parse_mode: 'Markdown')
        end
      end
    end
  end
end
