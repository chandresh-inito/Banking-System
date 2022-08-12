# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_08_12_090233) do

  create_table "accounts", force: :cascade do |t|
    t.integer "account_number"
    t.decimal "amount"
    t.string "account_type"
    t.integer "user_id"
    t.integer "branch_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["branch_id"], name: "index_accounts_on_branch_id"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "atms", force: :cascade do |t|
    t.date "expiry_date"
    t.integer "atm_card"
    t.string "cvv"
    t.integer "account_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_atms_on_account_id"
  end

  create_table "branches", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.integer "pincode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "loans", force: :cascade do |t|
    t.string "loan_type"
    t.decimal "amount"
    t.integer "duration"
    t.integer "account_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "principal"
    t.index ["account_id"], name: "index_loans_on_account_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "medium_of_transaction"
    t.integer "amount"
    t.string "credit_debit"
    t.string "from"
    t.string "where"
    t.integer "account_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
  end

# Could not dump table "users" because of following StandardError
#   Unknown type 'inet' for column 'current_sign_in_ip'

  add_foreign_key "accounts", "branches"
  add_foreign_key "accounts", "users"
  add_foreign_key "atms", "accounts"
  add_foreign_key "loans", "accounts"
  add_foreign_key "transactions", "accounts"
end
