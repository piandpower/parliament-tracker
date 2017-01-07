# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170107033046) do

  create_table "bills", force: :cascade do |t|
    t.date     "date_introduced"
    t.string   "prefix"
    t.integer  "number"
    t.string   "title_long"
    t.string   "title_short"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "bill_type"
    t.integer  "parliament_number"
    t.integer  "member_id"
    t.text     "summary"
    t.string   "last_event"
    t.date     "last_event_date"
    t.integer  "latest_publication"
  end

  add_index "bills", ["member_id"], name: "index_bills_on_member_id"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "electoral_districts", force: :cascade do |t|
    t.string   "name"
    t.text     "geo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "province"
    t.integer  "fednum"
  end

  create_table "members", force: :cascade do |t|
    t.integer  "party_id"
    t.string   "firstname"
    t.string   "lastname"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "email"
    t.string   "website"
    t.integer  "electoral_district_id"
    t.string   "honorific"
    t.string   "headshot_file_name"
    t.string   "headshot_content_type"
    t.integer  "headshot_file_size"
    t.datetime "headshot_updated_at"
    t.date     "date_elected"
    t.decimal  "vote_percent"
    t.boolean  "sitting",               default: true
  end

  add_index "members", ["electoral_district_id"], name: "index_members_on_electoral_district_id"
  add_index "members", ["party_id"], name: "index_members_on_party_id"

  create_table "members_news_articles", id: false, force: :cascade do |t|
    t.integer "news_article_id", null: false
    t.integer "member_id",       null: false
  end

  create_table "news_articles", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "outlet"
    t.date     "date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "link"
  end

  create_table "parties", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vote_tallies", force: :cascade do |t|
    t.boolean  "agreed_to"
    t.integer  "vote_number"
    t.date     "date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "para"
    t.integer  "bill_id"
    t.integer  "member_id"
  end

  add_index "vote_tallies", ["bill_id"], name: "index_vote_tallies_on_bill_id"
  add_index "vote_tallies", ["member_id"], name: "index_vote_tallies_on_member_id"

  create_table "votes", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "vote_tally_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "vote_decision"
  end

  add_index "votes", ["member_id"], name: "index_votes_on_member_id"
  add_index "votes", ["vote_tally_id"], name: "index_votes_on_vote_tally_id"

end
