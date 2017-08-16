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

ActiveRecord::Schema.define(version: 20170821173137) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activity_logs", force: :cascade do |t|
    t.integer  "organization_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "message"
    t.integer  "loggeable_id"
    t.string   "loggeable_type"
  end

  add_index "activity_logs", ["loggeable_type", "loggeable_id"], name: "index_activity_logs_on_loggeable_type_and_loggeable_id", using: :btree

  create_table "administrators", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "administrators", ["organization_id"], name: "index_administrators_on_organization_id", using: :btree
  add_index "administrators", ["user_id"], name: "index_administrators_on_user_id", using: :btree

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.string   "request_uuid"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "catalog_versions", force: :cascade do |t|
    t.integer  "catalog_id"
    t.json     "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "catalog_versions", ["catalog_id"], name: "index_catalog_versions_on_catalog_id", using: :btree

  create_table "catalogs", force: :cascade do |t|
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "published",                   default: false
    t.datetime "publish_date"
    t.string   "author",          limit: 255
  end

  add_index "catalogs", ["organization_id"], name: "index_catalogs_on_organization_id", using: :btree

  create_table "dataset_sectors", force: :cascade do |t|
    t.integer  "sector_id"
    t.integer  "dataset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dataset_sectors", ["dataset_id"], name: "index_dataset_sectors_on_dataset_id", using: :btree
  add_index "dataset_sectors", ["sector_id"], name: "index_dataset_sectors_on_sector_id", using: :btree

  create_table "datasets", force: :cascade do |t|
    t.text     "title"
    t.text     "description"
    t.text     "keyword"
    t.datetime "modified"
    t.string   "mbox",                limit: 255
    t.string   "temporal",            limit: 255
    t.string   "spatial",             limit: 255
    t.text     "landing_page"
    t.string   "accrual_periodicity", limit: 255
    t.integer  "catalog_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "publish_date"
    t.string   "contact_position",    limit: 255
    t.boolean  "public_access",                   default: true
    t.boolean  "editable",                        default: true
    t.datetime "issued"
    t.string   "contact_name"
    t.text     "comments"
    t.string   "state"
    t.string   "quality"
    t.datetime "temporal_init_date"
    t.datetime "temporal_term_date"
  end

  add_index "datasets", ["catalog_id"], name: "index_datasets_on_catalog_id", using: :btree

  create_table "designation_files", force: :cascade do |t|
    t.string   "file"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "designation_files", ["organization_id"], name: "index_designation_files_on_organization_id", using: :btree

  create_table "distributions", force: :cascade do |t|
    t.text     "title"
    t.text     "description"
    t.text     "download_url"
    t.string   "media_type",         limit: 255
    t.integer  "byte_size"
    t.string   "temporal",           limit: 255
    t.string   "spatial",            limit: 255
    t.integer  "dataset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "modified"
    t.string   "state",              limit: 255
    t.datetime "issued"
    t.datetime "publish_date"
    t.string   "format"
    t.text     "tools"
    t.text     "codelist"
    t.string   "codelist_link"
    t.string   "copyright"
    t.datetime "temporal_init_date"
    t.datetime "temporal_term_date"
  end

  add_index "distributions", ["dataset_id"], name: "index_distributions_on_dataset_id", using: :btree

  create_table "inventories", force: :cascade do |t|
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "authorization_file", limit: 255
    t.string   "designation_file"
  end

  add_index "inventories", ["organization_id"], name: "index_inventories_on_organization_id", using: :btree

  create_table "liaisons", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "liaisons", ["organization_id"], name: "index_liaisons_on_organization_id", using: :btree
  add_index "liaisons", ["user_id"], name: "index_liaisons_on_user_id", using: :btree

  create_table "memo_files", force: :cascade do |t|
    t.string   "file"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "memo_files", ["organization_id"], name: "index_memo_files_on_organization_id", using: :btree

  create_table "ministry_memo_files", force: :cascade do |t|
    t.string   "file"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "ministry_memo_files", ["organization_id"], name: "index_ministry_memo_files_on_organization_id", using: :btree

  create_table "organization_sectors", force: :cascade do |t|
    t.integer  "sector_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organization_sectors", ["organization_id"], name: "index_organization_sectors_on_organization_id", using: :btree
  add_index "organization_sectors", ["sector_id"], name: "index_organization_sectors_on_sector_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",            limit: 255
    t.text     "description"
    t.integer  "gov_type"
    t.text     "landing_page"
    t.boolean  "ranked",                      default: true
    t.boolean  "planea"
    t.boolean  "publica"
    t.boolean  "perfecciona"
    t.boolean  "promueve"
    t.boolean  "plan_inventario"
    t.boolean  "designaciones"
    t.boolean  "ministry",                    default: false
  end

  add_index "organizations", ["gov_type"], name: "index_organizations_on_gov_type", using: :btree
  add_index "organizations", ["slug"], name: "index_organizations_on_slug", unique: true, using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id"
    t.string   "resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sectors", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",       limit: 255
  end

  add_index "sectors", ["slug"], name: "index_sectors_on_slug", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255, default: "", null: false
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id"
    t.integer  "failed_attempts",                    default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["organization_id"], name: "index_users_on_organization_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  add_foreign_key "catalog_versions", "catalogs"
  add_foreign_key "designation_files", "organizations"
  add_foreign_key "memo_files", "organizations"
  add_foreign_key "ministry_memo_files", "organizations"
end
