class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.bigint :telegram_id
      t.integer :balance
      t.date :last_daily

      t.timestamps
    end
    add_index :users, :telegram_id, unique: true
  end
end
