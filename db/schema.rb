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

ActiveRecord::Schema.define(:version => 20151203065411) do

  create_table "attendances", :force => true do |t|
    t.integer  "user_id"
    t.date     "start_date"
    t.float    "days"
    t.boolean  "is_leave_or_wfh"
    t.text     "reason"
    t.boolean  "approval_status"
    t.text     "comments"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.date     "end_date"
    t.integer  "leave_type_id"
    t.string   "emails_to_notify"
    t.boolean  "is_escalated"
    t.boolean  "auto_approved"
  end

  create_table "leave_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles", :force => true do |t|
    t.integer  "working_days"
    t.string   "name"
    t.float    "leaves_applicable"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "roles_users", :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "name"
    t.integer  "manager_id"
    t.date     "join_date"
    t.date     "last_working_date"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.integer  "employee_code"
    t.float    "casual"
    t.float    "sick"
    t.float    "privilege"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
