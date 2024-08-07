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

ActiveRecord::Schema[7.1].define(version: 2024_07_23_024206) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "lessons", force: :cascade do |t|
    t.string "time"
    t.date "date"
    t.string "code"
    t.string "ls"
    t.string "text"
    t.boolean "peak", default: false
    t.boolean "blue", default: false
    t.boolean "booked", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "related", default: false
  end

  create_table "pulls", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scrapes", force: :cascade do |t|
    t.integer "yyyymm"
    t.string "user_id"
    t.integer "update_no"
    t.bigint "pull_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "comp_next", default: {}
    t.jsonb "comp_this", default: {}
    t.index ["pull_id"], name: "index_scrapes_on_pull_id"
  end

  create_table "slots", force: :cascade do |t|
    t.bigint "scrape_id"
    t.bigint "lesson_id"
    t.boolean "updated", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_slots_on_lesson_id"
    t.index ["scrape_id"], name: "index_slots_on_scrape_id"
  end

  add_foreign_key "scrapes", "pulls"
  add_foreign_key "slots", "lessons"
  add_foreign_key "slots", "scrapes"
end
