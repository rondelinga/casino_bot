class BetOutcome < ApplicationRecord
  belongs_to :bet
  has_many :bet_entries, dependent: :destroy
end
