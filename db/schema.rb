# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080925124449) do

# Could not dump table "contents" because of following StandardError
#   Unknown type 'tsvector' for column 'data_tsv'

  create_table "days", :force => true do |t|
    t.date    "dt"
    t.boolean "is_weekday"
    t.boolean "is_holiday"
    t.integer "y"
    t.integer "fy"
    t.integer "q"
    t.integer "m"
    t.integer "d"
    t.integer "dw"
    t.string  "monthname",  :limit => 9
    t.string  "dayname",    :limit => 9
    t.integer "w"
  end

  create_table "emails", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favorites", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.string   "target_type", :limit => 128, :null => false
    t.integer  "target_id",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_hierarchies", :force => true do |t|
    t.integer  "parent_group_id", :null => false
    t.integer  "parent_level",    :null => false
    t.integer  "child_group_id",  :null => false
    t.integer  "child_level",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.integer  "parent_id"
    t.string   "key",            :limit => 64,                 :null => false
    t.string   "name",           :limit => 128
    t.string   "url",            :limit => 512
    t.integer  "children_count",                :default => 0, :null => false
    t.integer  "lists_count",                   :default => 0, :null => false
    t.string   "domain",                                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier",     :limit => nil,                :null => false
    t.string   "description",    :limit => nil
  end

  add_index "groups", ["key", "parent_id"], :name => "index_groups_on_parent_id_and_key"

  create_table "list_alias", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lists", :force => true do |t|
    t.integer  "group_id"
    t.string   "address",            :limit => 128,                :null => false
    t.string   "url",                :limit => 512
    t.string   "subscriber_address", :limit => 128
    t.string   "key",                                              :null => false
    t.integer  "messages_count",                    :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identifier",         :limit => nil,                :null => false
    t.string   "description",        :limit => nil
  end

  add_index "lists", ["group_id", "key"], :name => "index_lists_on_group_id_and_key"

  create_table "message_references", :force => true do |t|
    t.integer  "message_id",                              :null => false
    t.string   "referenced_message_id822", :limit => 128, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "message_references", ["referenced_message_id822"], :name => "index_message_references_on_referenced_message_id822"
  add_index "message_references", ["message_id"], :name => "message_references_message_id"

# Could not dump table "messages" because of following StandardError
#   Unknown type 'tsvector' for column 'subject_tsv'

  create_table "parts", :force => true do |t|
    t.integer  "message_id",                                     :null => false
    t.string   "content_type", :limit => 128,                    :null => false
    t.string   "name"
    t.integer  "length"
    t.string   "state",        :limit => 1
    t.boolean  "clean",                       :default => false
    t.integer  "content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "parts", ["content_id"], :name => "index_parts_on_content_id"
  add_index "parts", ["message_id"], :name => "index_parts_on_message_id"
  add_index "parts", ["state"], :name => "part_state"

  create_table "ratings", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "message_id", :null => false
    t.integer  "value",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stop_words", :force => true do |t|
    t.string   "word",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "threads", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "identifier", :null => false
    t.string   "nickname"
    t.string   "fullname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "favorites", ["user_id"], "users", ["id"], :deferrable => true, :name => "favorites_user_id_fkey"

  add_foreign_key "group_hierarchies", ["parent_group_id"], "groups", ["id"], :name => "group_hierarchies_parent_group_id_fkey"
  add_foreign_key "group_hierarchies", ["child_group_id"], "groups", ["id"], :name => "group_hierarchies_child_group_id_fkey"

  add_foreign_key "groups", ["parent_id"], "groups", ["id"], :deferrable => true, :name => "groups_parent_id_fkey"

  add_foreign_key "lists", ["group_id"], "groups", ["id"], :name => "lists_group_id_fkey"

  add_foreign_key "message_references", ["message_id"], "messages", ["id"], :name => "message_references_message_id_fkey"

  add_foreign_key "parts", ["message_id"], "messages", ["id"], :name => "parts_message_id_fkey"
  add_foreign_key "parts", ["content_id"], "contents", ["id"], :name => "parts_content_id_fkey"

  add_foreign_key "ratings", ["user_id"], "users", ["id"], :deferrable => true, :name => "ratings_user_id_fkey"
  add_foreign_key "ratings", ["message_id"], "messages", ["id"], :deferrable => true, :name => "ratings_message_id_fkey"

end
