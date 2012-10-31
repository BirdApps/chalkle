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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121031011223) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "super",                  :default => false
    t.string   "name"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "bookings", :force => true do |t|
    t.integer  "meetup_id"
    t.integer  "lesson_id"
    t.integer  "chalkler_id"
    t.string   "status"
    t.integer  "guests"
    t.boolean  "paid"
    t.text     "meetup_data"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.decimal  "cost",        :precision => 8, :scale => 2
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "chalklers", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "meetup_id"
    t.text     "bio"
    t.text     "meetup_data"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  create_table "group_admins", :id => false, :force => true do |t|
    t.integer "group_id",      :null => false
    t.integer "admin_user_id", :null => false
  end

  add_index "group_admins", ["group_id", "admin_user_id"], :name => "index_group_admins_on_group_id_and_admin_user_id", :unique => true

  create_table "group_chalklers", :id => false, :force => true do |t|
    t.integer "group_id",    :null => false
    t.integer "chalkler_id", :null => false
  end

  add_index "group_chalklers", ["group_id", "chalkler_id"], :name => "index_group_chalklers_on_group_id_and_chalkler_id", :unique => true

  create_table "group_lessons", :id => false, :force => true do |t|
    t.integer "group_id",  :null => false
    t.integer "lesson_id", :null => false
  end

  add_index "group_lessons", ["group_id", "lesson_id"], :name => "index_group_lessons_on_group_id_and_lesson_id", :unique => true

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "api_key"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "url_name"
  end

  create_table "lessons", :force => true do |t|
    t.integer  "category_id"
    t.integer  "teacher_id"
    t.integer  "meetup_id"
    t.string   "name"
    t.string   "status"
    t.text     "description"
    t.decimal  "cost",         :precision => 8, :scale => 2
    t.datetime "start_at"
    t.integer  "duration"
    t.text     "meetup_data"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.decimal  "teacher_cost", :precision => 8, :scale => 2
    t.decimal  "venue_cost",   :precision => 8, :scale => 2
  end

  create_table "payments", :force => true do |t|
    t.integer  "booking_id"
    t.string   "xero_id"
    t.string   "xero_contact_id"
    t.string   "xero_contact_name"
    t.date     "date"
    t.boolean  "complete_record_downloaded"
    t.decimal  "total",                      :precision => 8, :scale => 2, :default => 0.0
    t.boolean  "reconciled"
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "teachers", :force => true do |t|
    t.string   "name"
    t.text     "qualification"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
