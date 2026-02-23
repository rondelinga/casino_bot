class SlotMachine
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

  def initialize(user)
    @user = user
  end

  def spin!
    return { error: :no_tokens } if @user.balance < SPIN_COST

    @user.update!(balance: @user.balance - SPIN_COST)

    keys = SYMBOLS.keys
    grid = Array.new(3) { Array.new(3) { keys.sample } }
    winnings, winning_lines = calculate_winnings(grid)

    @user.update!(balance: @user.balance + winnings) if winnings > 0

    {
      grid: grid,
      winnings: winnings,
      winning_lines: winning_lines,
      balance: @user.balance
    }
  end

  def display_grid(grid)
    grid.map { |row| display_row(row) }.join("\n")
  end

  private

  def calculate_winnings(grid)
    winnings = 0
    winning_lines = []

    grid.each_with_index do |row, i|
      if all_same?(row)
        payout = PAYOUTS[row[0]]
        winnings += payout
        winning_lines << "Ряд #{i + 1}: #{display_row(row)} +#{payout} 🎉"
      end
    end

    3.times do |col|
      column = grid.map { |row| row[col] }
      if all_same?(column)
        payout = PAYOUTS[column[0]]
        winnings += payout
        winning_lines << "Колонка #{col + 1}: #{display_row(column)} +#{payout} 🎉"
      end
    end

    diag1 = [grid[0][0], grid[1][1], grid[2][2]]
    diag2 = [grid[0][2], grid[1][1], grid[2][0]]

    if all_same?(diag1)
      payout = PAYOUTS[diag1[0]]
      winnings += payout
      winning_lines << "Диагональ ↘: #{display_row(diag1)} +#{payout} 🎉"
    end

    if all_same?(diag2)
      payout = PAYOUTS[diag2[0]]
      winnings += payout
      winning_lines << "Диагональ ↙: #{display_row(diag2)} +#{payout} 🎉"
    end

    [winnings, winning_lines]
  end

  def all_same?(arr)
    arr.uniq.length == 1
  end

  def display_row(row)
    row.map { |key| SYMBOLS[key] }.join(' ')
  end
end
