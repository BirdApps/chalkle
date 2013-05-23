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

ActiveRecord::Schema.define(:version => 20130523004611) do

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
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
    t.string   "role"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "bookings", :force => true do |t|
    t.integer  "meetup_id"
    t.integer  "lesson_id"
    t.integer  "chalkler_id"
    t.string   "status"
    t.integer  "guests",                                       :default => 0
    t.boolean  "paid"
    t.text     "meetup_data"
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
    t.boolean  "visible"
    t.decimal  "cost_override",  :precision => 8, :scale => 2
    t.string   "payment_method"
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
    t.string   "provider"
    t.string   "uid"
    t.string   "email_frequency"
    t.text     "email_categories"
    t.text     "email_streams"
    t.string   "phone_number"
  end

  create_table "channel_admins", :id => false, :force => true do |t|
    t.integer "channel_id",    :null => false
    t.integer "admin_user_id", :null => false
  end

  add_index "channel_admins", ["channel_id", "admin_user_id"], :name => "index_channel_admins_on_channel_id_and_admin_user_id", :unique => true

  create_table "channel_categories", :id => false, :force => true do |t|
    t.integer "channel_id",  :null => false
    t.integer "category_id", :null => false
  end

  add_index "channel_categories", ["channel_id", "category_id"], :name => "index_channel_categories_on_channel_id_and_category_id", :unique => true

  create_table "channel_chalklers", :id => false, :force => true do |t|
    t.integer "channel_id",  :null => false
    t.integer "chalkler_id", :null => false
  end

  add_index "channel_chalklers", ["channel_id", "chalkler_id"], :name => "index_channel_chalklers_on_channel_id_and_chalkler_id", :unique => true

  create_table "channel_lesson_suggestions", :id => false, :force => true do |t|
    t.integer "channel_id",           :null => false
    t.integer "lesson_suggestion_id", :null => false
  end

  add_index "channel_lesson_suggestions", ["channel_id", "lesson_suggestion_id"], :name => "cha_les_sug_index", :unique => true

  create_table "channel_lessons", :id => false, :force => true do |t|
    t.integer "channel_id", :null => false
    t.integer "lesson_id",  :null => false
  end

  add_index "channel_lessons", ["channel_id", "lesson_id"], :name => "index_channel_lessons_on_channel_id_and_lesson_id", :unique => true

  create_table "channels", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.string   "url_name"
    t.string   "email"
    t.decimal  "channel_percentage", :precision => 8, :scale => 4, :default => 0.125
    t.decimal  "teacher_percentage", :precision => 8, :scale => 4, :default => 0.125
    t.string   "account"
    t.boolean  "visible",                                          :default => false
  end

  create_table "cities", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "lesson_categories", :id => false, :force => true do |t|
    t.integer "lesson_id",   :null => false
    t.integer "category_id", :null => false
  end

  add_index "lesson_categories", ["lesson_id", "category_id"], :name => "index_lesson_categories_on_lesson_id_and_category_id", :unique => true

  create_table "lesson_images", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "lesson_id"
    t.string   "image_uid"
    t.string   "image_name"
  end

  create_table "lesson_suggestions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "category_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "chalkler_id"
  end

  create_table "lessons", :force => true do |t|
    t.integer  "teacher_id"
    t.integer  "meetup_id"
    t.string   "name"
    t.string   "status",                                                    :default => "Unreviewed"
    t.text     "description"
    t.decimal  "cost",                        :precision => 8, :scale => 2
    t.datetime "start_at"
    t.integer  "duration"
    t.text     "meetup_data"
    t.datetime "created_at",                                                                          :null => false
    t.datetime "updated_at",                                                                          :null => false
    t.decimal  "teacher_cost",                :precision => 8, :scale => 2
    t.decimal  "venue_cost",                  :precision => 8, :scale => 2
    t.boolean  "visible"
    t.decimal  "teacher_payment",             :precision => 8, :scale => 2
    t.string   "lesson_type"
    t.text     "teacher_bio"
    t.text     "do_during_class"
    t.text     "learning_outcomes"
    t.integer  "max_attendee"
    t.integer  "min_attendee",                                              :default => 2
    t.text     "availabilities"
    t.text     "prerequisites"
    t.text     "additional_comments"
    t.boolean  "donation",                                                  :default => false
    t.string   "lesson_skill"
    t.text     "venue"
    t.datetime "published_at"
    t.decimal  "channel_percentage_override", :precision => 8, :scale => 2
    t.decimal  "chalkle_percentage_override", :precision => 8, :scale => 2
    t.decimal  "material_cost",               :precision => 8, :scale => 2, :default => 0.0
    t.text     "suggested_audience"
    t.string   "meetup_url"
    t.decimal  "chalkle_payment",             :precision => 8, :scale => 2
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
    t.string   "reference"
    t.boolean  "visible"
    t.boolean  "cash_payment"
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

  create_table "streams", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "venues", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "meetup_id"
    t.string   "address_1",  :null => false
    t.float    "lat"
    t.float    "lon"
    t.integer  "city_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "address_2"
  end

end
