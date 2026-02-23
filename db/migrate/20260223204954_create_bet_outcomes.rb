class CreateBetOutcomes < ActiveRecord::Migration[8.1]
  def change
    create_table :bet_outcomes do |t|
      t.references :bet, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :position, null: false
      t.timestamps
    end
  end
end
