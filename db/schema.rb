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

ActiveRecord::Schema.define(version: 20151110141339) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "audit_logs", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "user_id"
    t.uuid     "project_id"
    t.uuid     "form_structure_id"
    t.text     "action"
    t.text     "old_data"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "form_question_id"
    t.string   "subject_id"
    t.uuid     "team_member_id"
    t.datetime "deleted_at"
    t.uuid     "form_structure_permission_id"
    t.string   "secondary_id"
  end

  add_index "audit_logs", ["action"], name: "index_audit_logs_on_action", using: :btree
  add_index "audit_logs", ["created_at"], name: "index_audit_logs_on_created_at", using: :btree
  add_index "audit_logs", ["deleted_at"], name: "index_audit_logs_on_deleted_at", using: :btree
  add_index "audit_logs", ["form_question_id"], name: "index_audit_logs_on_form_question_id", using: :btree
  add_index "audit_logs", ["form_structure_id"], name: "index_audit_logs_on_form_structure_id", using: :btree
  add_index "audit_logs", ["form_structure_permission_id"], name: "index_audit_logs_on_form_structure_permission_id", using: :btree
  add_index "audit_logs", ["project_id"], name: "index_audit_logs_on_project_id", using: :btree
  add_index "audit_logs", ["subject_id"], name: "index_audit_logs_on_subject_id", using: :btree
  add_index "audit_logs", ["team_member_id"], name: "index_audit_logs_on_team_member_id", using: :btree
  add_index "audit_logs", ["user_id"], name: "index_audit_logs_on_user_id", using: :btree

  create_table "demo_progresses", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "user_id"
    t.uuid     "project_id"
    t.uuid     "demo_form_id"
    t.uuid     "demo_question_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "project_index_global",                default: false
    t.boolean  "project_index_demo_project",          default: false
    t.boolean  "form_enter_edit",                     default: false
    t.boolean  "enter_edit_subject_id",               default: false
    t.boolean  "enter_edit_response",                 default: false
    t.boolean  "enter_edit_save",                     default: false
    t.boolean  "data_tab_emphasis",                   default: false
    t.boolean  "view_data_sort_search",               default: false
    t.boolean  "create_new_query",                    default: false
    t.boolean  "build_query_info",                    default: false
    t.boolean  "build_query_params",                  default: false
    t.boolean  "query_results_download",              default: false
    t.boolean  "query_results_breadcrumbs",           default: false
    t.boolean  "form_global",                         default: false
    t.boolean  "team_button",                         default: false
    t.boolean  "add_new_team_member",                 default: false
    t.boolean  "add_team_member_personal_details",    default: false
    t.boolean  "add_team_member_project_permissions", default: false
    t.boolean  "add_team_member_form_permissions",    default: false
    t.boolean  "import_button",                       default: false
    t.boolean  "import_overlays",                     default: false
    t.boolean  "import_csv_text",                     default: false
    t.boolean  "build_form_button",                   default: false
    t.boolean  "form_builder_info",                   default: false
    t.boolean  "build_form_add_question",             default: false
    t.boolean  "question_builder_prompt",             default: false
    t.boolean  "question_builder_variable",           default: false
    t.boolean  "question_builder_identifying",        default: false
  end

  create_table "form_answers", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "form_response_id"
    t.uuid     "form_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.text     "answer"
    t.boolean  "closed",            default: false
    t.uuid     "regular_exception"
    t.uuid     "year_exception"
    t.uuid     "month_exception"
    t.uuid     "day_exception"
    t.boolean  "ignore_error",      default: false
    t.text     "error_msg"
  end

  add_index "form_answers", ["deleted_at"], name: "index_form_answers_on_deleted_at", using: :btree
  add_index "form_answers", ["form_question_id"], name: "index_form_answers_on_form_question_id", using: :btree
  add_index "form_answers", ["form_response_id"], name: "index_form_answers_on_form_response_id", using: :btree

  create_table "form_question_conditions", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "form_question_id"
    t.uuid     "depends_on_id"
    t.text     "operator"
    t.text     "value"
    t.datetime "deleted_at"
  end

  add_index "form_question_conditions", ["deleted_at"], name: "index_form_question_conditions_on_deleted_at", using: :btree
  add_index "form_question_conditions", ["depends_on_id"], name: "index_form_question_conditions_on_depends_on_id", using: :btree
  add_index "form_question_conditions", ["form_question_id"], name: "index_form_question_conditions_on_form_question_id", using: :btree

  create_table "form_questions", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "form_structure_id"
    t.text     "prompt"
    t.text     "description"
    t.integer  "sequence_number"
    t.boolean  "personally_identifiable", default: false
    t.text     "question_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "variable_name"
    t.text     "display_number"
  end

  add_index "form_questions", ["deleted_at"], name: "index_form_questions_on_deleted_at", using: :btree
  add_index "form_questions", ["form_structure_id"], name: "index_form_questions_on_form_structure_id", using: :btree

  create_table "form_responses", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "form_structure_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "subject_id"
    t.integer  "instance_number"
    t.text     "secondary_id"
  end

  add_index "form_responses", ["deleted_at"], name: "index_form_responses_on_deleted_at", using: :btree
  add_index "form_responses", ["form_structure_id"], name: "index_form_responses_on_form_structure_id", using: :btree
  add_index "form_responses", ["subject_id"], name: "index_form_responses_on_subject_id", using: :btree

  create_table "form_structure_permissions", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "form_structure_id"
    t.uuid     "team_member_id"
    t.text     "permission_level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "form_structure_permissions", ["deleted_at"], name: "index_form_structure_permissions_on_deleted_at", using: :btree
  add_index "form_structure_permissions", ["form_structure_id"], name: "index_form_structure_permissions_on_form_structure_id", using: :btree
  add_index "form_structure_permissions", ["team_member_id"], name: "index_form_structure_permissions_on_team_member_id", using: :btree

  create_table "form_structures", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "project_id"
    t.datetime "deleted_at"
    t.boolean  "is_many_to_one"
    t.text     "secondary_id"
    t.boolean  "is_secondary_id_sorted"
    t.string   "description",            default: ""
    t.integer  "color_index"
  end

  add_index "form_structures", ["deleted_at"], name: "index_form_structures_on_deleted_at", using: :btree
  add_index "form_structures", ["project_id"], name: "index_form_structures_on_project_id", using: :btree

  create_table "numerical_range_configs", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid  "form_question_id"
    t.float "minimum_value"
    t.float "maximum_value"
    t.text  "precision"
  end

  add_index "numerical_range_configs", ["form_question_id"], name: "index_numerical_range_configs_on_form_question_id", using: :btree

  create_table "option_configs", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid    "form_question_id"
    t.integer "index"
    t.text    "value"
    t.boolean "other_option",        default: false
    t.text    "code"
    t.text    "other_variable_name"
  end

  add_index "option_configs", ["form_question_id"], name: "index_option_configs_on_form_question_id", using: :btree

  create_table "password_resets", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "password_resets", ["user_id"], name: "index_password_resets_on_user_id", using: :btree

  create_table "pending_users", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "user_id"
    t.uuid     "team_member_id"
    t.datetime "expires"
    t.text     "message"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pending_users", ["expires"], name: "index_pending_users_on_expires", using: :btree
  add_index "pending_users", ["user_id"], name: "index_pending_users_on_user_id", using: :btree

  create_table "project_backups", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.xml      "project_content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.uuid     "project_id"
  end

  add_index "project_backups", ["deleted_at"], name: "index_project_backups_on_deleted_at", using: :btree
  add_index "project_backups", ["project_id"], name: "index_project_backups_on_project_id", using: :btree

  create_table "projects", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "is_demo",     default: false
    t.string   "attribution", default: ""
  end

  add_index "projects", ["deleted_at"], name: "index_projects_on_deleted_at", using: :btree

  create_table "queries", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "owner_id"
    t.uuid     "editor_id"
    t.uuid     "project_id"
    t.text     "name"
    t.boolean  "is_shared"
    t.text     "conjunction"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_changed"
    t.text     "change_message"
  end

  add_index "queries", ["owner_id"], name: "index_queries_on_owner_id", using: :btree
  add_index "queries", ["project_id"], name: "index_queries_on_project_id", using: :btree

  create_table "query_form_structures", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "form_structure_id"
    t.uuid     "query_id"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "query_form_structures", ["form_structure_id"], name: "index_query_form_structures_on_form_structure_id", using: :btree
  add_index "query_form_structures", ["query_id"], name: "index_query_form_structures_on_query_id", using: :btree

  create_table "query_params", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "query_id"
    t.uuid     "form_question_id"
    t.text     "value"
    t.text     "operator"
    t.boolean  "is_last"
    t.integer  "sequence_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "is_many_to_one_instance"
    t.boolean  "is_many_to_one_count"
    t.uuid     "form_structure_id"
    t.boolean  "is_regular_exception"
    t.boolean  "is_year_exception"
    t.boolean  "is_month_exception"
    t.boolean  "is_day_exception"
  end

  add_index "query_params", ["query_id"], name: "index_query_params_on_query_id", using: :btree

  create_table "question_exceptions", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "form_question_id"
    t.text     "value"
    t.text     "label"
    t.text     "exception_type"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "session_tokens", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "user_id"
    t.datetime "last_activity_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "session_tokens", ["deleted_at"], name: "index_session_tokens_on_deleted_at", using: :btree

  create_table "team_members", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid     "project_id"
    t.uuid     "user_id"
    t.date     "expiration_date"
    t.boolean  "view_personally_identifiable_answers", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.boolean  "administrator",                        default: false
    t.boolean  "form_creation",                        default: false
    t.boolean  "audit",                                default: false
    t.boolean  "export",                               default: false
  end

  add_index "team_members", ["deleted_at"], name: "index_team_members_on_deleted_at", using: :btree
  add_index "team_members", ["project_id"], name: "index_team_members_on_project_id", using: :btree
  add_index "team_members", ["user_id"], name: "index_team_members_on_user_id", using: :btree

  create_table "text_configs", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.uuid "form_question_id"
    t.text "size"
  end

  add_index "text_configs", ["form_question_id"], name: "index_text_configs_on_form_question_id", using: :btree

  create_table "users", id: :uuid, default: "uuid_generate_v4()", force: true do |t|
    t.string   "email",               default: "",    null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "affiliation"
    t.string   "field_of_study"
    t.boolean  "super_user",          default: false
    t.string   "password_digest"
    t.string   "last_viewed_project"
    t.integer  "demo_progress",       default: 0
    t.string   "last_viewed_page"
    t.string   "phone_number",        default: ""
    t.boolean  "create",              default: false
    t.boolean  "import",              default: false
    t.boolean  "clean",               default: false
    t.boolean  "format",              default: false
    t.boolean  "invite",              default: false
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  add_foreign_key "audit_logs", "form_questions", name: "audit_logs_form_question_id_fk", dependent: :delete
  add_foreign_key "audit_logs", "form_structure_permissions", name: "audit_logs_form_structure_permission_id_fk", dependent: :delete
  add_foreign_key "audit_logs", "form_structures", name: "audit_logs_form_structure_id_fk", dependent: :delete
  add_foreign_key "audit_logs", "projects", name: "audit_logs_project_id_fk", dependent: :delete
  add_foreign_key "audit_logs", "team_members", name: "audit_logs_team_member_id_fk", dependent: :delete
  add_foreign_key "audit_logs", "users", name: "audit_logs_user_id_fk", dependent: :delete

  add_foreign_key "demo_progresses", "projects", name: "demo_progresses_project_id_fk", dependent: :delete

  add_foreign_key "form_answers", "form_questions", name: "form_answers_form_question_id_fk", dependent: :delete
  add_foreign_key "form_answers", "form_responses", name: "form_answers_form_response_id_fk", dependent: :delete

  add_foreign_key "form_question_conditions", "form_questions", name: "form_question_conditions_depends_on_id_fk", column: "depends_on_id"
  add_foreign_key "form_question_conditions", "form_questions", name: "form_question_conditions_form_question_id_fk"

  add_foreign_key "form_questions", "form_structures", name: "form_questions_form_structure_id_fk", dependent: :delete

  add_foreign_key "form_responses", "form_structures", name: "form_responses_form_structure_id_fk", dependent: :delete

  add_foreign_key "form_structure_permissions", "form_structures", name: "form_structure_permissions_form_structure_id_fk"
  add_foreign_key "form_structure_permissions", "team_members", name: "form_structure_permissions_team_member_id_fk"

  add_foreign_key "form_structures", "projects", name: "form_structures_project_id_fk", dependent: :delete

  add_foreign_key "numerical_range_configs", "form_questions", name: "numerical_range_configs_form_question_id_fk", dependent: :delete

  add_foreign_key "option_configs", "form_questions", name: "option_configs_form_question_id_fk", dependent: :delete

  add_foreign_key "password_resets", "users", name: "password_resets_user_id_fk", dependent: :delete

  add_foreign_key "pending_users", "users", name: "pending_users_user_id_fk", dependent: :delete

  add_foreign_key "project_backups", "projects", name: "project_backups_project_id_fk"

  add_foreign_key "queries", "projects", name: "queries_project_id_fk", dependent: :delete
  add_foreign_key "queries", "users", name: "queries_editor_id_fk", column: "editor_id", dependent: :delete
  add_foreign_key "queries", "users", name: "queries_owner_id_fk", column: "owner_id", dependent: :delete

  add_foreign_key "query_form_structures", "form_structures", name: "query_form_structures_form_structure_id_fk", dependent: :delete
  add_foreign_key "query_form_structures", "queries", name: "query_form_structures_query_id_fk", dependent: :delete

  add_foreign_key "query_params", "form_questions", name: "query_params_form_question_id_fk", dependent: :delete
  add_foreign_key "query_params", "form_structures", name: "query_params_form_structure_id_fk", dependent: :delete
  add_foreign_key "query_params", "queries", name: "query_params_query_id_fk", dependent: :delete

  add_foreign_key "question_exceptions", "form_questions", name: "question_exceptions_form_question_id_fk", dependent: :delete

  add_foreign_key "team_members", "projects", name: "team_members_project_id_fk", dependent: :delete
  add_foreign_key "team_members", "users", name: "team_members_user_id_fk", dependent: :delete

  add_foreign_key "text_configs", "form_questions", name: "text_configs_form_question_id_fk", dependent: :delete

end
