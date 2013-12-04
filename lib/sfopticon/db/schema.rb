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

ActiveRecord::Schema.define(version: 20131204233109) do

  create_table "branches", force: true do |t|
    t.string   "name"
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "environments", force: true do |t|
    t.string   "name",                          null: false
    t.string   "username"
    t.string   "password"
    t.string   "securitytoken"
    t.boolean  "production"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "locked",        default: false
    t.string   "host"
  end

  create_table "integration_branches", force: true do |t|
    t.string   "name",                        null: false
    t.integer  "source_env",                  null: false
    t.integer  "dest_env",                    null: false
    t.string   "commit_id"
    t.boolean  "is_deployed", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sf_objects", force: true do |t|
    t.string   "created_by_id"
    t.string   "created_by_name"
    t.datetime "created_date"
    t.string   "file_name"
    t.string   "full_name"
    t.string   "sfobject_id"
    t.string   "last_modified_by_id"
    t.string   "last_modified_by_name"
    t.datetime "last_modified_date"
    t.string   "manageable_state"
    t.string   "object_type"
    t.string   "namespace_prefix"
    t.integer  "environment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sf_objects", ["environment_id"], name: "index_sf_objects_on_environment_id", using: :btree
  add_index "sf_objects", ["file_name"], name: "index_sf_objects_on_file_name", using: :btree

end
