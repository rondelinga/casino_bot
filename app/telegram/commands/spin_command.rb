module Commands
    class SpinCommand < BaseCommand
      def call
        machine = SlotMachine.new(@user)
        result  = machine.spin!

        if result[:error] == :no_tokens
          @responder.send(
            "😢 Недостаточно токенов!\nПриходи завтра за новыми #{User::DAILY_TOKENS} токенами."
          )
        else
          @responder.send(build_text(machine, result))
        end
      end

      private

      def build_text(machine, result)
        grid_text = machine.display_grid(result[:grid])
        if result[:winnings] > 0
          lines_text = result[:winning_lines].join("\n")
          "🎰 Крутим...\n\n#{grid_text}\n\n#{lines_text}\n\n💰 Итого: +#{result[:winnings]} токенов\nБаланс: #{result[:balance]}"
        else
          "🎰 Крутим...\n\n#{grid_text}\n\n😔 Нет выигрышных комбинаций\nБаланс: #{result[:balance]}"
        end
      end
    end
end
