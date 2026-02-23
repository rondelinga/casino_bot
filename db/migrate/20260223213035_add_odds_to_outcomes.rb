class AddOddsToOutcomes < ActiveRecord::Migration[8.1]
  def change
    add_column :bet_outcomes, :odds, :decimal, precision: 5, scale: 2, null: false, default: 1.0
  end
end
