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

ActiveRecord::Schema[8.0].define(version: 2025_07_03_150014) do
  create_table "notification_deliveries", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "seminar_id", null: false
    t.datetime "delivered_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["delivered_at"], name: "index_notification_deliveries_on_delivered_at"
    t.index ["seminar_id"], name: "index_notification_deliveries_on_seminar_id"
    t.index ["user_id", "seminar_id"], name: "index_notification_deliveries_on_user_id_and_seminar_id", unique: true
    t.index ["user_id"], name: "index_notification_deliveries_on_user_id"
  end

  create_table "notification_requests", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "player_ids"
    t.string "city", limit: 100
    t.string "state", limit: 2
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city", "state"], name: "index_notification_requests_on_city_and_state"
    t.index ["user_id", "active"], name: "index_notification_requests_on_user_id_and_active"
    t.index ["user_id"], name: "index_notification_requests_on_user_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.string "nationality", limit: 100, null: false
    t.integer "team_id"
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_players_on_name"
    t.index ["nationality"], name: "index_players_on_nationality"
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "seminar_images", force: :cascade do |t|
    t.integer "seminar_id", null: false
    t.integer "position", null: false
    t.boolean "primary", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["seminar_id", "position"], name: "index_seminar_images_on_seminar_id_and_position", unique: true
    t.index ["seminar_id"], name: "index_seminar_images_on_seminar_id"
    t.index ["seminar_id"], name: "unique_primary_per_seminar", unique: true, where: "\"primary\" = true"
  end

  create_table "seminar_players", force: :cascade do |t|
    t.integer "seminar_id", null: false
    t.integer "player_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id", "seminar_id"], name: "index_seminar_players_on_player_id_and_seminar_id"
    t.index ["player_id"], name: "index_seminar_players_on_player_id"
    t.index ["seminar_id", "player_id"], name: "index_seminar_players_on_seminar_id_and_player_id", unique: true
    t.index ["seminar_id"], name: "index_seminar_players_on_seminar_id"
  end

  create_table "seminars", force: :cascade do |t|
    t.string "title", limit: 200, null: false
    t.text "description", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at"
    t.integer "user_id", null: false
    t.string "address", null: false
    t.string "city", limit: 100, null: false
    t.string "state", limit: 2, null: false
    t.string "zip_code", limit: 10
    t.string "country", limit: 2, default: "US", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city", "state"], name: "index_seminars_on_city_and_state"
    t.index ["country", "state", "city"], name: "index_seminars_on_country_and_state_and_city"
    t.index ["latitude", "longitude"], name: "index_seminars_on_latitude_and_longitude"
    t.index ["starts_at"], name: "index_seminars_on_starts_at"
    t.index ["user_id"], name: "index_seminars_on_user_id"
    t.check_constraint "ends_at IS NULL OR ends_at > starts_at", name: "seminars_valid_duration"
    t.check_constraint "starts_at > CURRENT_TIMESTAMP", name: "seminars_future_date"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "country", limit: 2, default: "US"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country"], name: "index_teams_on_country"
    t.index ["name"], name: "index_teams_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false, null: false
    t.integer "daily_seminar_count", default: 0, null: false
    t.datetime "last_seminar_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.check_constraint "daily_seminar_count >= 0 AND daily_seminar_count <= 25", name: "daily_seminar_count_range"
  end

  add_foreign_key "notification_deliveries", "seminars"
  add_foreign_key "notification_deliveries", "users"
  add_foreign_key "notification_requests", "users"
  add_foreign_key "players", "teams"
  add_foreign_key "seminar_images", "seminars"
  add_foreign_key "seminar_players", "players"
  add_foreign_key "seminar_players", "seminars"
  add_foreign_key "seminars", "users"
end
