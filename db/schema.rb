# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_23_213035) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bet_entries", force: :cascade do |t|
    t.integer "amount", null: false
    t.bigint "bet_id", null: false
    t.bigint "bet_outcome_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["bet_id", "user_id"], name: "index_bet_entries_on_bet_id_and_user_id", unique: true
    t.index ["bet_id"], name: "index_bet_entries_on_bet_id"
    t.index ["bet_outcome_id"], name: "index_bet_entries_on_bet_outcome_id"
    t.index ["user_id"], name: "index_bet_entries_on_user_id"
  end

  create_table "bet_outcomes", force: :cascade do |t|
    t.bigint "bet_id", null: false
    t.datetime "created_at", null: false
    t.decimal "odds", precision: 5, scale: 2, default: "1.0", null: false
    t.integer "position", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["bet_id"], name: "index_bet_outcomes_on_bet_id"
  end

  create_table "bets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "winning_outcome_index"
    t.index ["created_by_id"], name: "index_bets_on_created_by_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "balance"
    t.datetime "created_at", null: false
    t.date "last_daily"
    t.integer "role", default: 0, null: false
    t.bigint "telegram_id"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["telegram_id"], name: "index_users_on_telegram_id", unique: true
  end

  add_foreign_key "bet_entries", "bet_outcomes"
  add_foreign_key "bet_entries", "bets"
  add_foreign_key "bet_entries", "users"
  add_foreign_key "bet_outcomes", "bets"
  add_foreign_key "bets", "users", column: "created_by_id"
end
