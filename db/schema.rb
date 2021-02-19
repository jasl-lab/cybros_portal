# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_19_025152) do

  create_table "action_text_rich_texts", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "name", null: false
    t.text "body", size: :long
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "allowlisted_jwts", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "jti", null: false
    t.string "aud", null: false
    t.datetime "exp", null: false
    t.bigint "user_id", null: false
    t.index ["jti"], name: "index_allowlisted_jwts_on_jti", unique: true
    t.index ["user_id"], name: "index_allowlisted_jwts_on_user_id"
  end

  create_table "cad_operations", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "session_id"
    t.string "cmd_name"
    t.integer "cmd_seconds"
    t.json "cmd_data"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "seg_name"
    t.string "seg_function"
    t.index ["user_id"], name: "index_cad_operations_on_user_id"
  end

  create_table "cad_sessions", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "session"
    t.string "operation"
    t.string "ip_address"
    t.string "mac_address"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "begin_operation"
    t.string "end_operation"
    t.index ["user_id"], name: "index_cad_sessions_on_user_id"
  end

  create_table "copy_of_business_license_applies", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "employee_name"
    t.string "clerk_code"
    t.string "belong_company_name"
    t.string "belong_department_name"
    t.string "contract_belong_company"
    t.string "stamp_to_place"
    t.string "stamp_comment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "begin_task_id"
    t.boolean "backend_in_processing"
    t.text "bpm_message"
    t.string "belong_company_code"
    t.string "belong_department_code"
    t.string "contract_belong_company_code"
    t.string "status"
    t.index ["user_id"], name: "index_copy_of_business_license_applies_on_user_id"
  end

  create_table "cost_split_allocation_bases", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "base_name"
    t.string "company_code"
    t.integer "head_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "pmonth", null: false
  end

  create_table "department_users", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "department_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["department_id"], name: "index_department_users_on_department_id"
    t.index ["user_id"], name: "index_department_users_on_user_id"
  end

  create_table "departments", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "company_name"
    t.string "dept_code"
    t.string "company_code"
  end

  create_table "direct_question_answers", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "knowledge_id", null: false
    t.bigint "direct_question_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["direct_question_id"], name: "index_direct_question_answers_on_direct_question_id"
    t.index ["knowledge_id"], name: "index_direct_question_answers_on_knowledge_id"
  end

  create_table "direct_questions", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "question"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "knowledge_likes", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "like_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_knowledge_likes_on_user_id"
  end

  create_table "knowledges", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "category_1"
    t.string "category_2"
    t.string "question", collation: "utf8_general_ci"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "category_3"
    t.boolean "shanghai_only", default: false
  end

  create_table "manual_cw_access_codes", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.string "cw_rolename"
    t.string "org_code"
    t.string "dept_code"
    t.boolean "auto_generated_role"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_manual_cw_access_codes_on_user_id"
  end

  create_table "manual_hr_access_codes", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "hr_rolename"
    t.string "org_code"
    t.string "dept_code"
    t.boolean "auto_generated_role", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_manual_hr_access_codes_on_user_id"
  end

  create_table "manual_operation_access_codes", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "code"
    t.string "org_code"
    t.string "dept_code"
    t.string "title"
    t.integer "job_level"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_manual_operation_access_codes_on_user_id"
  end

  create_table "monthly_salary_split_rules", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_job_type_id", null: false
    t.bigint "user_salary_classification_id", null: false
    t.bigint "user_cost_type_id", null: false
    t.date "month"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_cost_type_id"], name: "index_monthly_salary_split_rules_on_user_cost_type_id"
    t.index ["user_job_type_id"], name: "index_monthly_salary_split_rules_on_user_job_type_id"
    t.index ["user_salary_classification_id"], name: "idx_monthly_salary_split_rules_on_salary_classification_id"
  end

  create_table "name_card_applies", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "english_name"
    t.string "department_name"
    t.string "en_department_name"
    t.string "title"
    t.string "en_title"
    t.string "phone_ext"
    t.string "fax_no"
    t.string "mobile"
    t.integer "print_out_box_number"
    t.string "begin_task_id"
    t.text "bpm_message"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "company_name"
    t.string "en_company_name"
    t.string "comment"
    t.string "office_address"
    t.string "office_level"
    t.string "professional_title"
    t.string "en_professional_title"
    t.string "chinese_name"
    t.string "email"
    t.boolean "backend_in_processing", default: false
    t.string "thickness"
    t.string "back_color"
    t.index ["user_id"], name: "index_name_card_applies_on_user_id"
  end

  create_table "name_card_black_titles", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "original_title"
    t.string "required_title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "name_card_white_titles", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "original_title"
    t.string "required_title"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "official_stamp_usage_applies", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.string "employee_name"
    t.string "clerk_code"
    t.string "belong_company_name"
    t.string "belong_company_code"
    t.string "belong_department_name"
    t.string "belong_department_code"
    t.string "application_class"
    t.string "stamp_to_place"
    t.string "stamp_comment"
    t.string "begin_task_id"
    t.string "backend_in_processing"
    t.text "bpm_message"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "application_subclasses", default: "--- []\n"
    t.index ["user_id"], name: "index_official_stamp_usage_applies_on_user_id"
  end

  create_table "pending_questions", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "question"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "owner_id"
    t.index ["owner_id"], name: "index_pending_questions_on_owner_id"
    t.index ["user_id"], name: "index_pending_questions_on_user_id"
  end

  create_table "position_users", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "position_id", null: false
    t.boolean "main_position"
    t.string "post_level"
    t.bigint "user_job_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["position_id"], name: "index_position_users_on_position_id"
    t.index ["user_id"], name: "index_position_users_on_user_id"
    t.index ["user_job_type_id"], name: "index_position_users_on_user_job_type_id"
  end

  create_table "positions", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.string "functional_category"
    t.bigint "department_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["department_id"], name: "index_positions_on_department_id"
  end

  create_table "proof_of_employment_applies", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id"
    t.string "employee_name"
    t.string "clerk_code"
    t.string "belong_company_name"
    t.string "belong_department_name"
    t.string "contract_belong_company"
    t.string "stamp_to_place"
    t.string "stamp_comment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "begin_task_id"
    t.boolean "backend_in_processing"
    t.text "bpm_message"
    t.string "belong_company_code"
    t.string "belong_department_code"
    t.string "contract_belong_company_code"
    t.string "status"
    t.index ["user_id"], name: "index_proof_of_employment_applies_on_user_id"
  end

  create_table "proof_of_income_applies", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "employee_name"
    t.string "clerk_code"
    t.string "belong_company_name"
    t.string "belong_department_name"
    t.string "contract_belong_company"
    t.string "stamp_to_place"
    t.string "stamp_comment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "begin_task_id"
    t.boolean "backend_in_processing"
    t.text "bpm_message"
    t.string "belong_company_code"
    t.string "belong_department_code"
    t.string "contract_belong_company_code"
    t.string "status"
    t.index ["user_id"], name: "index_proof_of_income_applies_on_user_id"
  end

  create_table "public_rental_housing_applies", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "employee_name"
    t.string "clerk_code"
    t.string "belong_company_name"
    t.string "belong_department_name"
    t.string "contract_belong_company"
    t.string "stamp_to_place"
    t.string "stamp_comment"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "begin_task_id"
    t.boolean "backend_in_processing"
    t.text "bpm_message"
    t.string "belong_company_code"
    t.string "belong_department_code"
    t.string "contract_belong_company_code"
    t.string "status"
    t.index ["user_id"], name: "index_public_rental_housing_applies_on_user_id"
  end

  create_table "report_names", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "controller_name"
    t.string "report_name"
  end

  create_table "report_view_histories", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "controller_name"
    t.string "action_name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.index ["user_id"], name: "index_report_view_histories_on_user_id"
  end

  create_table "role_users", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "auto_generated", default: false
    t.index ["role_id"], name: "index_role_users_on_role_id"
    t.index ["user_id"], name: "index_role_users_on_user_id"
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "role_name"
    t.boolean "report_viewer"
    t.boolean "report_reviewer"
    t.boolean "knowledge_maintainer"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "cad_session"
    t.boolean "report_view_all"
    t.boolean "project_map_viewer"
    t.boolean "hr_group_rt_reader"
    t.boolean "hr_subsidiary_rt_reader"
    t.boolean "hr_report_writer"
    t.boolean "hr_group_reader"
    t.boolean "hr_subsidiary_reader"
    t.boolean "report_company_detail_viewer"
    t.boolean "large_customer_detail_viewser"
    t.boolean "group_report_viewer", default: false
    t.boolean "org_viewer", default: false
    t.boolean "project_map_contract_download", default: false, null: false
  end

  create_table "split_cost_item_details", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "split_cost_item_id", null: false
    t.date "month"
    t.string "to_split_company_code"
    t.decimal "group_cost", precision: 10
    t.decimal "shanghai_area_cost", precision: 10
    t.decimal "shanghai_hq_cost", precision: 10
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "split_cost_item_category"
    t.string "from_dept_code"
    t.string "bill_no"
    t.decimal "group_cost_numerator", precision: 10
    t.decimal "shanghai_area_cost_numerator", precision: 10
    t.decimal "shanghai_hq_cost_numerator", precision: 10
    t.index ["split_cost_item_id"], name: "index_split_cost_item_details_on_split_cost_item_id"
  end

  create_table "split_cost_item_group_rate_companies", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "split_cost_item_id"
    t.string "company_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["split_cost_item_id"], name: "idx_split_cost_group_rate_on_companies_id"
  end

  create_table "split_cost_item_shanghai_area_rate_companies", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "split_cost_item_id"
    t.string "company_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["split_cost_item_id"], name: "idx_split_cost_shanghai_area_rate_on_companies_id"
  end

  create_table "split_cost_item_shanghai_hq_rate_companies", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "split_cost_item_id"
    t.string "company_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["split_cost_item_id"], name: "idx_split_cost_shanghai_hq_rate_on_companies_id"
  end

  create_table "split_cost_items", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.integer "group_rate"
    t.integer "shanghai_area"
    t.integer "shanghai_hq"
    t.integer "version"
    t.date "start_date"
    t.date "end_date"
    t.string "group_rate_base"
    t.string "shanghai_area_base"
    t.string "shanghai_hq_base"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "split_cost_item_no"
    t.string "split_cost_item_name"
    t.string "split_cost_item_category"
    t.string "from_dept_code"
  end

  create_table "user_cost_types", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_job_types", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_monthly_part_time_split_rates", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "month"
    t.bigint "position_id", null: false
    t.boolean "main_position"
    t.bigint "user_salary_classification_id", null: false
    t.integer "salary_classification_split_rate"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["position_id"], name: "index_user_monthly_part_time_split_rates_on_position_id"
    t.index ["user_id"], name: "index_user_monthly_part_time_split_rates_on_user_id"
    t.index ["user_salary_classification_id"], name: "idx_user_monthly_part_time_split_rates_on_classification_id"
  end

  create_table "user_salary_classifications", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_split_classify_salaries", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "belong_company_name"
    t.string "belong_department_name"
    t.string "job_position"
    t.date "month"
    t.decimal "amount", precision: 10
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_job_type_id"
    t.bigint "user_salary_classification_id"
    t.index ["user_id"], name: "index_user_split_classify_salaries_on_user_id"
    t.index ["user_job_type_id"], name: "index_user_split_classify_salaries_on_user_job_type_id"
    t.index ["user_salary_classification_id"], name: "idx_user_split_classify_salaries_on_salary_classification_id"
  end

  create_table "user_split_cost_details", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "v_wata_dept_code"
    t.bigint "user_id", null: false
    t.date "month"
    t.string "to_split_company_code"
    t.decimal "group_cost", precision: 10
    t.decimal "shanghai_area_cost", precision: 10
    t.decimal "shanghai_hq_cost", precision: 10
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "group_cost_numerator", precision: 10
    t.decimal "shanghai_area_cost_numerator", precision: 10
    t.decimal "shanghai_hq_cost_numerator", precision: 10
    t.index ["user_id"], name: "index_user_split_cost_details_on_user_id"
  end

  create_table "user_split_cost_group_rate_companies", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_split_cost_setting_id"
    t.string "company_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_split_cost_setting_id"], name: "idx_split_cost_group_rate_on_setting_id"
  end

  create_table "user_split_cost_settings", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.integer "group_rate", null: false
    t.integer "shanghai_area", null: false
    t.integer "shanghai_hq", null: false
    t.bigint "user_id", null: false
    t.integer "version"
    t.date "start_date"
    t.date "end_date"
    t.string "org_code", null: false
    t.string "dept_code", null: false
    t.string "position_title", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "group_rate_base"
    t.string "shanghai_area_base"
    t.string "shanghai_hq_base"
    t.index ["user_id"], name: "index_user_split_cost_settings_on_user_id"
  end

  create_table "user_split_cost_shanghai_area_rate_companies", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_split_cost_setting_id"
    t.string "company_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_split_cost_setting_id"], name: "idx_split_cost_shanghai_area_rate_on_setting_id"
  end

  create_table "user_split_cost_shanghai_hq_rate_companies", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "user_split_cost_setting_id"
    t.string "company_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_split_cost_setting_id"], name: "idx_split_cost_shanghai_hq_rate_on_setting_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "position_title"
    t.string "clerk_code"
    t.string "chinese_name"
    t.string "desk_phone"
    t.string "job_level"
    t.string "wecom_id"
    t.string "pre_sso_id"
    t.string "mobile"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "wechat_sessions", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "openid", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "greating_time"
    t.index ["openid"], name: "index_wechat_sessions_on_openid", unique: true
  end

  create_table "wechat_users", charset: "utf8mb4", force: :cascade do |t|
    t.string "app_id", null: false, comment: "微信APPID"
    t.string "open_id", null: false, comment: "微信用户OPENID"
    t.string "union_id", comment: "微信UNIONID"
    t.string "mobile", default: "", null: false, comment: "手机号"
    t.string "nick_name", default: "", null: false, comment: "昵称"
    t.string "avatar_url", default: "", null: false, comment: "头像"
    t.integer "gender", default: 0, null: false, comment: "性别 0：未知、1：男、2：女"
    t.string "province", default: "", null: false, comment: "省"
    t.string "city", default: "", null: false, comment: "市"
    t.string "country", default: "", null: false, comment: "国家"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["app_id", "open_id"], name: "index_wechat_users_on_app_id_and_open_id", unique: true
    t.index ["mobile"], name: "index_wechat_users_on_mobile"
    t.index ["union_id"], name: "index_wechat_users_on_union_id"
    t.index ["user_id"], name: "index_wechat_users_on_user_id"
  end

  create_table "yingjianke_overrun_users", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.datetime "time"
    t.string "device"
    t.decimal "stay_timespan", precision: 10
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "allowlisted_jwts", "users", on_delete: :cascade
  add_foreign_key "cad_operations", "users"
  add_foreign_key "copy_of_business_license_applies", "users"
  add_foreign_key "direct_question_answers", "direct_questions"
  add_foreign_key "direct_question_answers", "knowledges"
  add_foreign_key "knowledge_likes", "users"
  add_foreign_key "manual_hr_access_codes", "users"
  add_foreign_key "manual_operation_access_codes", "users"
  add_foreign_key "monthly_salary_split_rules", "user_cost_types"
  add_foreign_key "monthly_salary_split_rules", "user_job_types"
  add_foreign_key "monthly_salary_split_rules", "user_salary_classifications"
  add_foreign_key "name_card_applies", "users"
  add_foreign_key "position_users", "positions"
  add_foreign_key "position_users", "users"
  add_foreign_key "proof_of_income_applies", "users"
  add_foreign_key "public_rental_housing_applies", "users"
  add_foreign_key "report_view_histories", "users"
  add_foreign_key "split_cost_item_details", "split_cost_items"
  add_foreign_key "user_monthly_part_time_split_rates", "positions"
  add_foreign_key "user_monthly_part_time_split_rates", "user_salary_classifications"
  add_foreign_key "user_monthly_part_time_split_rates", "users"
  add_foreign_key "user_split_classify_salaries", "users"
  add_foreign_key "user_split_cost_settings", "users"
  add_foreign_key "wechat_users", "users"
end
