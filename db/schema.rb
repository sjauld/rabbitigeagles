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

ActiveRecord::Schema.define(version: 20151021043320) do

  create_table "payments", force: :cascade do |t|
    t.float    "amount"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tips", force: :cascade do |t|
    t.string   "old_username"
    t.string   "sport"
    t.string   "description"
    t.datetime "matchtime"
    t.float    "odds"
    t.integer  "tippingweek"
    t.boolean  "successful"
    t.boolean  "locked"
    t.boolean  "deleted"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "week_id"
    t.integer  "user_id"
    t.float    "contribution"
  end

  add_index "tips", ["user_id"], name: "index_tips_on_user_id"
  add_index "tips", ["week_id"], name: "index_tips_on_week_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean  "is_admin"
  end

  create_table "weeks", force: :cascade do |t|
    t.integer  "tippingweek"
    t.float    "bettingamount"
    t.float    "betreturn"
    t.boolean  "locked"
    t.boolean  "deleted",       default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.float    "return"
    t.integer  "correct_tips"
  end

end
