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

ActiveRecord::Schema[8.1].define(version: 2026_02_25_130000) do
  create_table "quiz_sessions", force: :cascade do |t|
    t.text "answers_json"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "result_label", null: false
    t.string "result_type", null: false
    t.integer "season_id", null: false
    t.string "source"
    t.datetime "started_at"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["completed_at"], name: "index_quiz_sessions_on_completed_at"
    t.index ["season_id"], name: "index_quiz_sessions_on_season_id"
    t.index ["user_id", "season_id"], name: "index_quiz_sessions_on_user_id_and_season_id", unique: true
    t.index ["user_id"], name: "index_quiz_sessions_on_user_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "ended_at"
    t.string "name", null: false
    t.datetime "started_at"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_seasons_on_active"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "language_code", default: "ru"
    t.string "last_name"
    t.string "telegram_id", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["telegram_id"], name: "index_users_on_telegram_id", unique: true
  end

  add_foreign_key "quiz_sessions", "seasons"
  add_foreign_key "quiz_sessions", "users"
end
