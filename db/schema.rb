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

ActiveRecord::Schema[7.2].define(version: 2026_04_14_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "feedbacks", force: :cascade do |t|
    t.bigint "match_report_id", null: false
    t.string "analyzer", null: false
    t.integer "severity", default: 0, null: false
    t.string "category", null: false
    t.string "title", null: false
    t.text "description"
    t.text "actionable_tip"
    t.float "confidence_score", default: 0.0
    t.json "raw_payload", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_report_id", "category"], name: "index_feedbacks_on_match_report_id_and_category"
    t.index ["match_report_id", "severity"], name: "index_feedbacks_on_match_report_id_and_severity"
    t.index ["match_report_id"], name: "index_feedbacks_on_match_report_id"
  end

  create_table "match_reports", force: :cascade do |t|
    t.string "match_id", null: false
    t.bigint "player_id", null: false
    t.string "map", null: false
    t.integer "status", default: 0, null: false
    t.string "score"
    t.integer "duration_seconds"
    t.json "team_ct_ids", default: []
    t.json "team_t_ids", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_match_reports_on_match_id", unique: true
    t.index ["player_id"], name: "index_match_reports_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "steam_id", null: false
    t.string "username", null: false
    t.integer "rank", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["steam_id"], name: "index_players_on_steam_id", unique: true
  end

  add_foreign_key "feedbacks", "match_reports"
  add_foreign_key "match_reports", "players"
end
