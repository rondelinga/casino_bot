class Bet < ApplicationRecord
  enum :status, { open: 0, closed: 1, resolved: 2, cancelled: 3 }

  belongs_to :created_by, class_name: 'User'
  has_many :bet_outcomes, -> { order(:position) }, dependent: :destroy
  has_many :bet_entries, dependent: :destroy

  def total_pool
    bet_entries.sum(:amount)
  end

  def resolve!(winning_outcome_id)
    return unless open? || closed?

    winning_outcome = bet_outcomes.find(winning_outcome_id)
    winning_entries = bet_entries.where(bet_outcome: winning_outcome)
    winning_pool = winning_entries.sum(:amount)

    if winning_pool > 0
      pool = total_pool.to_f
      winning_entries.each do |entry|
        payout = (entry.amount / winning_pool.to_f * pool).floor
        entry.user.update!(balance: entry.user.balance + payout)
      end
    end

    update!(status: :resolved, winning_outcome_index: winning_outcome.position)
  end

  def cancel!
    bet_entries.each do |entry|
      entry.user.update!(balance: entry.user.balance + entry.amount)
    end
    update!(status: :cancelled)
  end

  def odds_for(outcome)
    outcome_pool = bet_entries.where(bet_outcome: outcome).sum(:amount).to_f
    return 1.0 if outcome_pool == 0 || total_pool == 0
    (total_pool.to_f / outcome_pool).round(2)
  end

  def summary
    lines = ["📊 *#{title}*\n"]
    bet_outcomes.each do |outcome|
      pool = bet_entries.where(bet_outcome: outcome).sum(:amount)
      odds = odds_for(outcome)
      lines << "#{outcome.position}. #{outcome.title} — #{pool} токенов (x#{odds})"
    end
    lines << "\n💰 Общий банк: #{total_pool} токенов"
    lines.join("\n")
  end
end
