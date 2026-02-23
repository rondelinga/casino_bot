class CreateBets < ActiveRecord::Migration[8.1]
  def change
    create_table :bets do |t|
      t.string :title, null: false
      t.integer :status, default: 0, null: false
      t.integer :winning_outcome_index
      t.references :created_by, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end
