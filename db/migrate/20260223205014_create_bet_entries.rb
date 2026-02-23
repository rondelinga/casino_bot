class CreateBetEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :bet_entries do |t|
      t.references :bet, null: false, foreign_key: true
      t.references :bet_outcome, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :amount, null: false
      t.timestamps
    end

    add_index :bet_entries, [:bet_id, :user_id], unique: true
  end
end
