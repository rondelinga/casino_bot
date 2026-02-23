class BetEntry < ApplicationRecord
  belongs_to :bet
  belongs_to :bet_outcome
  belongs_to :user
end
