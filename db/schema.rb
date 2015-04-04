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

ActiveRecord::Schema.define(version: 20150404092707) do

  create_table "friendships", force: :cascade do |t|
    t.integer  "requester_id"
    t.integer  "friend_id"
    t.integer  "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "images", force: :cascade do |t|
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "S3Image_file_name"
    t.string   "S3Image_content_type"
    t.integer  "S3Image_file_size"
    t.datetime "S3Image_updated_at"
    t.integer  "user_id"
    t.integer  "visibility"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.integer  "role"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
