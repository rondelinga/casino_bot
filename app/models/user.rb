class User < ApplicationRecord
  DAILY_TOKENS = 100
  SPIN_COST = 10

  SYMBOLS = {
    diamond: '💎',
    bell:    '🔔',
    orange:  '🍊',
    lemon:   '🍋',
    cherry:  '🍒',
  }

  PAYOUTS = {
    diamond: 100,
    bell:    50,
    orange:  30,
    lemon:   20,
    cherry:  15,
  }

  def self.find_or_create_by_telegram(telegram_id)
    user = find_or_create_by(telegram_id: telegram_id)
    user.give_daily_tokens!
    user
  end

  def give_daily_tokens!
    if last_daily.nil? || last_daily < Date.today
      update!(balance: balance.to_i + DAILY_TOKENS, last_daily: Date.today)
    end
  end

  def spin!
    return :no_tokens if balance < SPIN_COST

    update!(balance: balance - SPIN_COST)

    keys = SYMBOLS.keys
    grid = Array.new(3) { Array.new(3) { keys.sample } }

    winnings = 0
    winning_lines = []

    grid.each_with_index do |row, i|
      if row[0] == row[1] && row[1] == row[2]
        payout = PAYOUTS[row[0]]
        winnings += payout
        winning_lines << "Ряд #{i + 1}: #{display_row(row)} +#{payout} 🎉"
      end
    end

    3.times do |col|
      column = [grid[0][col], grid[1][col], grid[2][col]]
      if column[0] == column[1] && column[1] == column[2]
        payout = PAYOUTS[column[0]]
        winnings += payout
        winning_lines << "Колонка #{col + 1}: #{display_row(column)} +#{payout} 🎉"
      end
    end
    
    diag1 = [grid[0][0], grid[1][1], grid[2][2]]
    diag2 = [grid[0][2], grid[1][1], grid[2][0]]

    if diag1[0] == diag1[1] && diag1[1] == diag1[2]
      payout = PAYOUTS[diag1[0]]
      winnings += payout
      winning_lines << "Диагональ ↘: #{display_row(diag1)} +#{payout} 🎉"
    end

    if diag2[0] == diag2[1] && diag2[1] == diag2[2]
      payout = PAYOUTS[diag2[0]]
      winnings += payout
      winning_lines << "Диагональ ↙: #{display_row(diag2)} +#{payout} 🎉"
    end

    update!(balance: balance + winnings) if winnings > 0

    {
      grid: grid,
      winnings: winnings,
      winning_lines: winning_lines,
      balance: balance
    }
  end

  def display_grid(grid)
    grid.map { |row| display_row(row) }.join("\n")
  end

  private

  def display_row(row)
    row.map { |key| SYMBOLS[key] }.join(' ')
  end
end
