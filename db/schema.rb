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

ActiveRecord::Schema.define(:version => 20141008002354) do

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
    t.integer  "course_id"
    t.integer  "chalkler_id"
    t.string   "status",                                              :default => "yes"
    t.integer  "guests",                                              :default => 0
    t.text     "meetup_data"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
    t.boolean  "visible",                                             :default => true
    t.decimal  "paid",                  :precision => 8, :scale => 2
    t.string   "payment_method"
    t.datetime "reminder_last_sent_at"
    t.decimal  "chalkle_fee"
    t.decimal  "chalkle_gst"
    t.string   "chalkle_gst_number"
    t.decimal  "teacher_fee"
    t.decimal  "teacher_gst"
    t.string   "teacher_gst_number"
    t.decimal  "provider_fee"
    t.decimal  "provider_gst"
    t.string   "provider_gst_number"
    t.decimal  "processing_fee"
    t.decimal  "processing_gst"
    t.string   "note_to_teacher"
    t.string   "name"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "parent_id"
    t.integer  "colour_num"
    t.boolean  "primary",    :default => false
    t.string   "url_name"
  end

  create_table "chalklers", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "bio"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "encrypted_password",     :default => "",       :null => false
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
    t.string   "email_frequency",        :default => "weekly"
    t.text     "email_categories"
    t.string   "phone_number"
    t.text     "email_region_ids"
    t.boolean  "visible",                :default => true
    t.float    "latitude"
    t.float    "longitude"
    t.string   "address"
    t.string   "avatar"
  end

  create_table "channel_admins", :force => true do |t|
    t.integer "channel_id",    :null => false
    t.integer "admin_user_id"
    t.integer "chalkler_id"
  end

  add_index "channel_admins", ["channel_id", "admin_user_id"], :name => "index_channel_admins_on_channel_id_and_admin_user_id", :unique => true

  create_table "channel_categories", :id => false, :force => true do |t|
    t.integer "channel_id",  :null => false
    t.integer "category_id", :null => false
  end

  add_index "channel_categories", ["channel_id", "category_id"], :name => "index_channel_categories_on_channel_id_and_category_id", :unique => true

  create_table "channel_contacts", :force => true do |t|
    t.integer  "channel_id"
    t.integer  "chalkler_id"
    t.string   "to"
    t.string   "from"
    t.string   "subject"
    t.string   "message"
    t.string   "status"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "channel_course_suggestions", :id => false, :force => true do |t|
    t.integer "channel_id",           :null => false
    t.integer "course_suggestion_id", :null => false
  end

  add_index "channel_course_suggestions", ["channel_id", "course_suggestion_id"], :name => "cha_les_sug_index", :unique => true

  create_table "channel_courses", :id => false, :force => true do |t|
    t.integer "channel_id", :null => false
    t.integer "course_id",  :null => false
  end

  add_index "channel_courses", ["channel_id", "course_id"], :name => "index_channel_courses_on_channel_id_and_course_id", :unique => true

  create_table "channel_photos", :force => true do |t|
    t.integer  "channel_id"
    t.string   "image"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "channel_plans", :force => true do |t|
    t.string   "name"
    t.integer  "max_channel_admins"
    t.integer  "max_teachers"
    t.integer  "max_free_class_attendees"
    t.decimal  "class_attendee_cost"
    t.decimal  "course_attendee_cost"
    t.decimal  "annual_cost"
    t.decimal  "processing_fee_percent"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "channel_regions", :force => true do |t|
    t.integer "channel_id"
    t.integer "region_id"
  end

  add_index "channel_regions", ["channel_id", "region_id"], :name => "index_channel_regions_on_channel_id_and_region_id", :unique => true

  create_table "channel_teachers", :force => true do |t|
    t.integer "channel_id",                               :null => false
    t.integer "chalkler_id"
    t.string  "name"
    t.string  "bio"
    t.string  "pseudo_chalkler_email"
    t.boolean "can_make_classes",      :default => false
    t.string  "tax_number"
    t.string  "account"
    t.string  "avatar"
  end

  create_table "channels", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                                                     :null => false
    t.datetime "updated_at",                                                                     :null => false
    t.string   "url_name"
    t.string   "email"
    t.decimal  "channel_rate_override",         :precision => 8, :scale => 4
    t.decimal  "teacher_percentage",            :precision => 8, :scale => 4, :default => 0.75
    t.string   "account"
    t.boolean  "visible",                                                     :default => false
    t.text     "description"
    t.string   "website_url"
    t.string   "logo"
    t.string   "meetup_url"
    t.string   "short_description"
    t.string   "hero"
    t.integer  "channel_plan_id"
    t.string   "plan_name"
    t.integer  "plan_max_channel_admins"
    t.integer  "plan_max_free_class_attendees"
    t.decimal  "plan_class_attendee_cost"
    t.decimal  "plan_course_attendee_cost"
    t.decimal  "plan_annual_cost"
    t.decimal  "plan_processing_fee_percent"
    t.string   "tax_number"
    t.string   "average_hero_color"
    t.integer  "plan_max_teachers"
  end

  create_table "cities", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "course_images", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "course_id"
    t.string   "image_uid"
    t.string   "image_name"
  end

  create_table "course_suggestions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "category_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "chalkler_id"
  end

  create_table "courses", :force => true do |t|
    t.integer  "teacher_id"
    t.string   "name"
    t.string   "status",                                            :default => "Unreviewed"
    t.text     "description"
    t.decimal  "cost",                :precision => 8, :scale => 2
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
    t.decimal  "teacher_cost",        :precision => 8, :scale => 2
    t.boolean  "visible",                                           :default => true
    t.decimal  "teacher_payment",     :precision => 8, :scale => 2
    t.string   "course_type"
    t.text     "do_during_class"
    t.text     "learning_outcomes"
    t.integer  "max_attendee"
    t.integer  "min_attendee",                                      :default => 2
    t.text     "availabilities"
    t.text     "prerequisites"
    t.text     "additional_comments"
    t.string   "course_skill"
    t.text     "venue"
    t.datetime "published_at"
    t.text     "suggested_audience"
    t.decimal  "chalkle_payment",     :precision => 8, :scale => 2
    t.string   "course_upload_image"
    t.integer  "category_id"
    t.decimal  "cached_channel_fee",  :precision => 8, :scale => 2
    t.decimal  "cached_chalkle_fee",  :precision => 8, :scale => 2
    t.integer  "channel_id"
    t.integer  "region_id"
    t.integer  "repeat_course_id"
    t.string   "url_name"
    t.string   "street_number"
    t.string   "street_name"
    t.string   "city"
    t.string   "postal_code"
    t.float    "longitude"
    t.float    "latitude"
    t.string   "venue_address"
    t.datetime "start_at"
    t.string   "teacher_pay_type"
    t.string   "course_class_type"
    t.string   "note_to_attendees"
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

  create_table "event_logs", :force => true do |t|
    t.string   "name"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.string   "state",        :default => "new"
    t.string   "error"
  end

  create_table "lessons", :force => true do |t|
    t.integer  "course_id"
    t.datetime "start_at"
    t.integer  "duration"
    t.boolean  "cancelled", :default => false
  end

  create_table "omni_avatar_avatars", :force => true do |t|
    t.integer "owner_id"
    t.string  "owner_type"
    t.string  "image"
    t.string  "provider_name"
    t.string  "original_url"
  end

  create_table "omniauth_identities", :force => true do |t|
    t.integer "user_id"
    t.string  "email"
    t.string  "provider"
    t.string  "uid"
    t.string  "name"
    t.text    "provider_data"
  end

  add_index "omniauth_identities", ["email"], :name => "index_omniauth_identities_on_email"
  add_index "omniauth_identities", ["provider", "uid"], :name => "index_omniauth_identities_on_provider_and_uid"
  add_index "omniauth_identities", ["user_id"], :name => "index_omniauth_identities_on_user_id"

  create_table "partner_inquiries", :force => true do |t|
    t.string   "name"
    t.string   "organisation"
    t.string   "location"
    t.string   "contact_details"
    t.text     "comment"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
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

  create_table "regions", :force => true do |t|
    t.string "name"
    t.string "url_name"
  end

  create_table "repeat_courses", :force => true do |t|
  end

  create_table "streams", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "subscriptions", :force => true do |t|
    t.integer "channel_id",  :null => false
    t.integer "chalkler_id", :null => false
  end

  add_index "subscriptions", ["channel_id", "chalkler_id"], :name => "index_channel_chalklers_on_channel_id_and_chalkler_id", :unique => true

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

  add_foreign_key "channel_admins", "chalklers", name: "channel_admins_chalkler_id_fk"

  add_foreign_key "channel_regions", "channels", name: "channel_regions_channel_id_fk"
  add_foreign_key "channel_regions", "regions", name: "channel_regions_region_id_fk"

  add_foreign_key "channel_teachers", "chalklers", name: "channel_teachers_chalkler_id_fk"
  add_foreign_key "channel_teachers", "channels", name: "channel_teachers_channel_id_fk"

  add_foreign_key "courses", "regions", name: "courses_region_id_fk"

end
