class User < ApplicationRecord
  DAILY_TOKENS = 100

  enum :role, { regular: 0, creator: 1, admin: 2 }

  def give_daily_tokens!
    return if last_daily.present? && last_daily >= Date.today
    update!(balance: balance.to_i + DAILY_TOKENS, last_daily: Date.today)
  end

  def self.find_or_create_by_telegram(telegram_id)
    user = find_or_create_by(telegram_id: telegram_id)
    user.give_daily_tokens!
    user
  end
end
