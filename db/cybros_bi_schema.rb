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

ActiveRecord::Schema.define(version: 2020_10_09_011647) do

  create_table "ACCOUNT_RECEIVE_SAVEDATE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "kporg"
    t.text "kporgcode"
    t.text "kpdeptcode"
    t.text "kpdept"
    t.text "sqdeptcode"
    t.text "sqdept"
    t.text "htcode"
    t.text "htname"
    t.text "kh"
    t.float "kpe", limit: 53
    t.datetime "kpdate"
    t.float "ssk", limit: 53
    t.text "billdate_s"
    t.float "ysk", limit: 53
    t.text "ysdate"
    t.float "bjsr", limit: 53
    t.text "tpdate"
    t.text "khfar"
    t.text "khjt"
    t.text "billno"
    t.text "pmbillno"
    t.text "skzy"
    t.text "fpbillno"
    t.text "bz"
    t.text "billdate_m"
    t.text "sktype"
    t.text "tepy"
    t.date "savedate"
  end

  create_table "BI_MESSAGE_BOX", primary_key: "MESSAGEID", id: :integer, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "title", limit: 200, null: false, comment: "文档标题"
    t.text "text"
    t.string "messagetype", limit: 200
    t.string "status", limit: 200
    t.string "creater", limit: 200
    t.datetime "create_time"
  end

  create_table "BI_VIEW_HISTORIES", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "访问链接"
    t.string "报表名字", limit: 200
    t.string "行为", limit: 100
    t.datetime "访问时间"
    t.string "工号", limit: 50
    t.string "姓名", limit: 50
  end

  create_table "COMPLETE_VALUE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "orgcode"
    t.text "orgcode_sum"
    t.date "month"
    t.float "total", limit: 53
    t.float "cum_total", limit: 53
    t.date "date"
  end

  create_table "COMPLETE_VALUE_DEPT", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "orgcode_sum"
    t.text "orgcode"
    t.text "deptcode_sum"
    t.text "deptcode"
    t.date "month"
    t.float "total", limit: 53
    t.float "cum_total", limit: 53
    t.date "date"
  end

  create_table "COMPLETE_VALUE_DETAIL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "projectcode"
    t.text "projectname"
    t.text "contractcode"
    t.text "salescontractname"
    t.float "addvalue", limit: 53
    t.float "reducevalue", limit: 53
    t.float "sumamount", limit: 53
    t.date "confirmdate"
    t.text "orgcode_sum"
    t.text "orgname_sum"
    t.string "orgcode", limit: 50
    t.string "orgname", limit: 100
    t.text "deptcode_sum"
    t.text "deptname_sum"
    t.text "deptcode"
    t.text "deptname"
    t.date "date"
    t.index ["date", "orgname"], name: "IDX_DATE_ORGNAME"
  end

  create_table "CONTRACT_HOLD", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "id"
    t.string "orgcode_sum", limit: 50
    t.string "orgcode", limit: 50
    t.string "deptcode_sum", limit: 50
    t.string "deptcode", limit: 50
    t.float "busiretentcontract", limit: 53
    t.float "busiretentnocontract", limit: 53
    t.date "date"
  end

  create_table "CONTRACT_HOLD_SIGN_DETAIL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "id"
    t.text "projectitemcode"
    t.text "projectitemname"
    t.text "contractcode"
    t.text "contractname"
    t.text "profession"
    t.string "orgcode_sum", limit: 20
    t.text "orgcode"
    t.text "deptcode_sum"
    t.text "deptcode"
    t.float "output", limit: 53
    t.float "milestone", limit: 53
    t.float "sign_hold_value", limit: 53
    t.date "date"
  end

  create_table "CONTRACT_HOLD_UNSIGN_DETAIL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "id"
    t.text "projectitemcode"
    t.text "projectitemname"
    t.text "contractcode"
    t.text "contractname"
    t.text "profession"
    t.string "orgcode_sum", limit: 20
    t.text "orgcode"
    t.text "deptcode_sum"
    t.text "deptcode"
    t.float "planning_output", limit: 53
    t.float "workhour_cost", limit: 53
    t.float "unsign_hold_value", limit: 53
    t.date "date"
  end

  create_table "CONTRACT_PRICE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "projectcode", limit: 50
    t.text "projectname"
    t.string "salescontractcode", limit: 50
    t.text "salescontractname"
    t.string "contractstatusname", limit: 50
    t.string "contractcategoryname", limit: 50
    t.string "contractpropertyname", limit: 50
    t.text "belongcompanyname"
    t.float "realamounttotal", limit: 53
    t.string "scaletypecnname", limit: 50
    t.float "scalearea", limit: 53
    t.string "provincename", limit: 50
    t.string "area", limit: 50
    t.string "cityname", limit: 50
    t.string "areaname", limit: 50
    t.date "filingtime"
    t.string "businessltdcode", limit: 50
    t.text "businessltdname"
    t.string "businessdepartmentscode", limit: 50
    t.text "businessdepartmentsname"
    t.string "operationgenrename", limit: 50
    t.string "projectgenername", limit: 50
    t.string "buildinggenrename", limit: 50
    t.string "projectbigstagename", limit: 50
    t.string "stagename", limit: 50
    t.float "scale", limit: 53
    t.float "univalence", limit: 53
    t.string "unitsname", limit: 50
    t.float "subtotal", limit: 53
    t.float "discounttotal", limit: 53
    t.string "citylevel", limit: 50
    t.string "projecttype", limit: 50
    t.string "projectstage", limit: 50
    t.float "frontpart", limit: 53
    t.float "rearpart", limit: 53
    t.float "parttotal", limit: 53
  end

  create_table "CONTRACT_PRODUCTION_DEPT", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "orgcode_sum"
    t.text "orgcode"
    t.text "deptcode_sum"
    t.text "deptcode"
    t.datetime "filingtime"
    t.float "deptvalue", limit: 53
    t.float "marketbouns", limit: 53
    t.float "clientbouns", limit: 53
    t.float "total", limit: 53
    t.float "cum_deptvalue", limit: 53
    t.float "cum_marketbouns", limit: 53
    t.float "cum_clientbouns", limit: 53
    t.float "cum_total", limit: 53
    t.date "date"
  end

  create_table "CONTRACT_PRODUCTION_DEPT_RECORD", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "orgcode_sum"
    t.text "orgcode"
    t.text "deptcode_sum"
    t.text "deptcode"
    t.datetime "filingtime"
    t.float "deptvalue", limit: 53
    t.float "marketbouns", limit: 53
    t.float "clientbouns", limit: 53
    t.float "total", limit: 53
    t.float "cum_deptvalue", limit: 53
    t.float "cum_marketbouns", limit: 53
    t.float "cum_clientbouns", limit: 53
    t.float "cum_total", limit: 53
    t.date "date"
  end

  create_table "CONTRACT_PRODUCTION_DETAIL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "salescontractcode"
    t.text "salescontractname"
    t.text "contractstatusname"
    t.datetime "filingtime"
    t.text "orgcode"
    t.text "orgname"
    t.text "deptcode"
    t.text "deptname"
    t.float "deptvalue", limit: 53
    t.float "marketbouns", limit: 53
    t.float "clientbouns", limit: 53
    t.float "total", limit: 53
    t.text "deptcode_sum"
    t.text "deptname_sum"
    t.text "orgcode_sum"
    t.text "orgname_sum"
    t.date "date"
  end

  create_table "CONTRACT_PRODUCTION_DETAIL_RECORD", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "salescontractcode"
    t.text "salescontractname"
    t.text "contractstatusname"
    t.datetime "filingtime"
    t.text "orgcode"
    t.text "orgname"
    t.text "deptcode"
    t.text "deptname"
    t.float "deptvalue", limit: 53
    t.float "marketbouns", limit: 53
    t.float "clientbouns", limit: 53
    t.float "total", limit: 53
    t.text "deptcode_sum"
    t.text "deptname_sum"
    t.text "orgcode_sum"
    t.text "orgname_sum"
    t.date "date"
  end

  create_table "CONTRACT_SIGN", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "orgcode_sum"
    t.text "orgcode"
    t.datetime "filingtime"
    t.float "contract_amount", limit: 53
    t.float "count", limit: 53
    t.float "contract_period", limit: 53
    t.float "period_mean", limit: 53
    t.float "cum_amount", limit: 53
    t.float "cum_count", limit: 53
    t.float "cum_period", limit: 53
    t.float "cum_period_mean", limit: 53
    t.date "date"
  end

  create_table "CONTRACT_SIGN_DEPT", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "orgcode_sum"
    t.text "orgcode"
    t.text "deptcode_sum"
    t.text "deptcode"
    t.datetime "filingtime"
    t.float "contract_amount", limit: 53
    t.float "count", limit: 53
    t.float "contract_period", limit: 53
    t.float "period_mean", limit: 53
    t.float "cum_amount", limit: 53
    t.float "cum_count", limit: 53
    t.float "cum_period", limit: 53
    t.float "cum_period_mean", limit: 53
    t.date "date"
  end

  create_table "CONTRACT_SIGN_DEPT_RECORD", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "orgcode_sum"
    t.text "orgcode"
    t.text "deptcode_sum"
    t.text "deptcode"
    t.datetime "filingtime"
    t.float "contract_amount", limit: 53
    t.float "count", limit: 53
    t.float "contract_period", limit: 53
    t.float "period_mean", limit: 53
    t.float "cum_amount", limit: 53
    t.float "cum_count", limit: 53
    t.float "cum_period", limit: 53
    t.float "cum_period_mean", limit: 53
    t.date "date"
  end

  create_table "CONTRACT_SIGN_DETAIL_AMOUNT", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "salescontractcode"
    t.text "salescontractname"
    t.text "belongcompanyname"
    t.date "filingtime"
    t.float "realamounttotal", limit: 53
    t.text "orgcode"
    t.text "orgname"
    t.text "deptcode"
    t.text "deptname"
    t.text "businessdirectorname"
    t.text "orgcode_sum"
    t.text "orgname_sum"
    t.text "deptcode_sum"
    t.text "deptname_sum"
    t.date "date"
  end

  create_table "CONTRACT_SIGN_DETAIL_AMOUNT_RECORD", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "salescontractcode"
    t.text "salescontractname"
    t.text "belongcompanyname"
    t.datetime "filingtime"
    t.float "realamounttotal", limit: 53
    t.text "orgcode"
    t.text "orgname"
    t.text "deptcode"
    t.text "deptname"
    t.text "businessdirectorname"
    t.text "deptcode_sum"
    t.text "deptname_sum"
    t.text "orgcode_sum"
    t.text "orgname_sum"
    t.date "date"
  end

  create_table "CONTRACT_SIGN_DETAIL_DATE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "projectcode"
    t.text "projectname"
    t.text "businessdirectorname"
    t.text "salescontractcode"
    t.text "salescontractname"
    t.text "contractstatusname"
    t.text "firstpartyname"
    t.text "contractpropertyname"
    t.string "amounttotal", limit: 20
    t.decimal "date1", precision: 10
    t.decimal "date2", precision: 10
    t.date "filingtime"
    t.date "mintimecardfill"
    t.date "mindatehrcostamount"
    t.text "projecttype"
    t.string "orgcode_sum", limit: 20
    t.string "orgname_sum", limit: 45
    t.string "orgcode", limit: 20
    t.string "orgname", limit: 45
    t.string "deptcode_sum", limit: 20
    t.string "deptname_sum", limit: 45
    t.string "deptcode", limit: 20
    t.string "deptname", limit: 45
    t.boolean "need_hide"
    t.string "provincename", limit: 45
  end

  create_table "CW_CASHFLOW_FILL", primary_key: "deptcode", id: { type: :string, limit: 45 }, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.date "createdate"
    t.string "deptleader", limit: 45
    t.string "deptbusitype", limit: 45
  end

  create_table "HR_MONTH_REPORT", primary_key: ["deptcode", "savedate"], charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "orgcode_sum", limit: 50
    t.string "orgcode", limit: 50
    t.string "deptcode_sum", limit: 50
    t.string "deptcode", limit: 50, null: false
    t.float "staff_now", limit: 53
    t.float "staff_pro", limit: 53
    t.float "staff_art", limit: 53
    t.float "turn_in", limit: 53
    t.float "turn_out", limit: 53
    t.float "turn", limit: 53
    t.float "staff_in", limit: 53
    t.float "staff_out", limit: 53
    t.float "realdate", limit: 53
    t.float "realdate_pro", limit: 53
    t.float "realdate_art", limit: 53
    t.float "predict_staff_in", limit: 53
    t.float "deptdate", limit: 53
    t.date "savedate", null: false
    t.float "dept_sum_turn_in", limit: 53
    t.float "dept_sum_turn_out", limit: 53
    t.float "org_turn_in", limit: 53
    t.float "org_turn_out", limit: 53
    t.float "org_sum_turn_in", limit: 53
    t.float "org_sum_turn_out", limit: 53
  end

  create_table "ORG_ORDER", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "org_name"
    t.float "org_order", limit: 53
    t.string "org_code", limit: 45
    t.string "org_shortname", limit: 45
    t.string "org_type", limit: 45
  end

  create_table "ORG_REPORT_DEPT_ORDER", primary_key: "index", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "编号", limit: 45
    t.string "部门", limit: 45
    t.string "上级部门编号", limit: 45
    t.string "上级部门", limit: 45
    t.string "组织编号", limit: 45
    t.string "组织", limit: 45
    t.date "开始时间"
    t.date "结束时间"
    t.text "部门类型"
    t.text "部门类别"
    t.float "是否启用", limit: 53
    t.integer "部门排名", default: 9999
    t.integer "显示顺序", default: 9999
    t.float "是否显示", limit: 53
    t.string "部门属性", limit: 45
    t.index ["index"], name: "index_UNIQUE", unique: true
  end

  create_table "ORG_REPORT_RELATION_ORDER", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "code", limit: 45
    t.string "depttype", limit: 45
    t.datetime "enddate"
    t.string "glbdef1", limit: 45
    t.integer "inuse"
    t.string "isbusinessunit", limit: 45
    t.string "name", limit: 200
    t.integer "order", default: 9999
    t.integer "order_nc", default: 9999
    t.datetime "startdate"
    t.string "upcode", limit: 45
    t.string "upname", limit: 200
    t.integer "visible", limit: 1
    t.string "deptattribute", limit: 45
  end

  create_table "ORG_SHORTNAME", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "pk_org", limit: 100
    t.string "code", limit: 45
    t.string "name", limit: 45
    t.string "shortname", limit: 45
    t.string "isbusinessunit", limit: 10
    t.index ["code", "shortname"], name: "code_idx"
  end

  create_table "PK_CODE_NAME", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "orgcode"
    t.text "pk_org"
    t.text "orgname"
    t.text "deptcode"
    t.text "pk_dept"
    t.text "deptname"
    t.float "displayorder", limit: 53
  end

  create_table "PM_BONUSALLOCATIONDET_SAVE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "id"
    t.text "bizorgcode"
    t.text "createdbizorgcode"
    t.datetime "createddate"
    t.text "createdorgcode"
    t.text "creatorcode"
    t.bigint "dataversion"
    t.text "orgcode"
    t.text "redactorcode"
    t.text "redatebizorgcode"
    t.datetime "redatedate"
    t.text "redateorgcode"
    t.text "remark"
    t.text "status"
    t.text "allocationid"
    t.float "allocationmoney", limit: 53
    t.text "allocationreason"
    t.text "incomcode"
    t.text "incomid"
    t.text "incomname"
    t.text "indeptcode"
    t.text "indeptid"
    t.text "indeptname"
    t.text "outcomcode"
    t.text "outcomid"
    t.text "outcomname"
    t.text "outdeptcode"
    t.text "outdeptid"
    t.text "outdeptname"
    t.text "adjusttype"
    t.text "businesstype"
    t.float "changemoney", limit: 53
    t.text "projectbigstage"
    t.text "projectcategory"
    t.text "settlementrate"
    t.text "projectitemcode"
    t.text "projectitemid"
    t.text "projectitemname"
    t.text "agentcode"
    t.text "agentid"
    t.text "agentname"
    t.text "savedate"
    t.datetime "refreshdate"
  end

  create_table "PM_BONUSALLOCATION_SAVE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "id"
    t.text "bizorgcode"
    t.text "createdbizorgcode"
    t.datetime "createddate"
    t.text "createdorgcode"
    t.text "creatorcode"
    t.bigint "dataversion"
    t.text "orgcode"
    t.text "redactorcode"
    t.text "redatebizorgcode"
    t.datetime "redatedate"
    t.text "redateorgcode"
    t.text "remark"
    t.text "status"
    t.text "allocationno"
    t.text "allocationstatus"
    t.datetime "approvedate"
    t.bigint "attachcount"
    t.text "linkaddress"
    t.text "synergyremark"
    t.text "savedate"
    t.datetime "refreshdate"
  end

  create_table "PREDICT_MONEY_RECEIVE_DEPT", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "orgcode"
    t.text "orgname"
    t.text "deptcode"
    t.text "deptname"
    t.text "f_month"
    t.float "nextmonthmoney", limit: 53
    t.bigint "settlemoney"
    t.bigint "sixmonthmoney"
    t.datetime "refresh_date"
  end

  create_table "PREDICT_MONEY_RECEIVE_ORG", primary_key: ["orgcode", "f_month", "refresh_date"], charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "orgcode_sum", limit: 45
    t.string "orgcode", limit: 45, null: false
    t.string "orgname_sum", limit: 200
    t.string "orgname", limit: 200
    t.string "f_month", limit: 45, null: false
    t.float "nextmonthmoney", limit: 53
    t.bigint "settlemoney"
    t.bigint "sixmonthmoney"
    t.datetime "refresh_date", null: false
  end

  create_table "PROVINCE_NEW_AREA", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.integer "year"
    t.integer "month"
    t.string "province", limit: 100
    t.float "new_area"
    t.datetime "date"
  end

  create_table "PV_BASIC", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "项目"
    t.text "系统ID"
    t.float "装机容量", limit: 53
    t.text "天气地点"
  end

  create_table "PV_DAYS_RECORD", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "项目"
    t.text "系统ID"
    t.float "发电量", limit: 53
    t.float "辐照值", limit: 53
    t.float "PR", limit: 53
    t.date "日期"
    t.index ["id"], name: "index_UNIQUE", unique: true
  end

  create_table "PV_INCOME", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "项目编号"
    t.text "项目名称"
    t.text "地点"
    t.datetime "并网时间"
    t.text "计费周期"
    t.date "月份"
    t.float "发电量", limit: 53
    t.float "上网电量", limit: 53
    t.float "自用电费", limit: 53
    t.float "标杆\n电价", limit: 53
    t.float "上网电费", limit: 53
    t.float "国家补贴\n电价", limit: 53
    t.float "国家补贴金额(元)", limit: 53
    t.float "地方补贴电价", limit: 53
    t.float "地方补贴金额（元）", limit: 53
    t.float "补贴收入", limit: 53
    t.float "自发自用率", limit: 53
    t.float "其他收入", limit: 53
    t.float "总收入", limit: 53
    t.float "自用电价", limit: 53
    t.float "当月度电收益", limit: 53
  end

  create_table "PV_MONTH_RECORD", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "项目"
    t.text "系统ID"
    t.date "日期"
    t.float "发电量", limit: 53
    t.float "辐照值", limit: 53
    t.float "PR", limit: 53
    t.index ["id"], name: "id_UNIQUE", unique: true
  end

  create_table "REFRESH_RECORD", primary_key: "program", id: { type: :string, limit: 100 }, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.datetime "refresh_date"
    t.integer "isinuse", limit: 1, default: 1
    t.integer "checkdate", default: 1
  end

  create_table "SA_PROJECT_OPPORTUNITY", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "projectcode", limit: 200
    t.text "projectname"
    t.string "opportunitycode", limit: 200
    t.text "opportunityname"
    t.string "opportunitystatus", limit: 200
    t.date "traceassigndate"
    t.string "clientsname", limit: 200
    t.string "belongcompanyname", limit: 200
    t.float "contractamount", limit: 53
    t.string "businessdirectororgname", limit: 200
    t.string "businessdirectordeptname", limit: 200
    t.string "businessdirectorname", limit: 200
    t.string "clueprovidename", limit: 200
    t.string "areatype", limit: 200
    t.float "area", limit: 53
    t.string "mainbusinesstypename", limit: 200
    t.string "projecttype", limit: 200
    t.string "projectbigstage", limit: 200
    t.string "servicestage", limit: 200
    t.string "coworkapproachname", limit: 200
    t.string "isplan", limit: 200
    t.date "contractdate"
    t.float "successrate", limit: 53
    t.float "contractconvert", limit: 53
    t.date "finishdate"
    t.string "refusereason", limit: 200
  end

  create_table "SH_REFRESH_RATE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "work_no"
    t.text "work_name"
    t.bigint "total_count"
    t.float "refresh_count", limit: 53
    t.date "date"
    t.text "orgcode"
    t.text "deptcode"
  end

  create_table "SH_REFRESH_RATE_DETAIL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "projectitemcode"
    t.text "projectitemname"
    t.text "orgcode"
    t.text "deptcode"
    t.text "projectpacode"
    t.text "projectpaname"
    t.text "businesstypecnname"
    t.text "projectcategorycnname"
    t.text "projectbigstagecnname"
    t.text "projectstagecnname"
    t.float "projectprocess", limit: 53
    t.text "iscontract"
    t.float "hours", limit: 53, default: 0.0
    t.datetime "begindate"
    t.date "date"
  end

  create_table "SH_STAFF_COUNT", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "deptcode"
    t.text "f_month"
    t.float "avgamount", limit: 53
    t.text "deptname"
  end

  create_table "STAFF_COUNT", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "orgcode", limit: 45
    t.date "f_month"
    t.float "avg_work", limit: 53
    t.float "avg_work1", limit: 53
  end

  create_table "SUB_COMPANY_NEED_RECEIVE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "orgcode_sum", limit: 20
    t.string "orgcode", limit: 20
    t.string "deptcode_sum", limit: 20
    t.string "deptcode", limit: 20
    t.float "busi_unsign_receive", limit: 53
    t.float "busi_sign_receive", limit: 53
    t.float "account_need_receive", limit: 53
    t.float "account_longbill", limit: 53
    t.float "account_shortbill", limit: 53
    t.date "date", null: false
  end

  create_table "SUB_COMPANY_NEED_RECEIVE_ACCOUNT_DETAIL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "kporgcode", limit: 20
    t.string "orgcode_sum", limit: 20
    t.string "orgcode", limit: 20
    t.string "deptcode_sum", limit: 20
    t.string "deptcode", limit: 20
    t.string "contractcode", limit: 20
    t.text "contractname"
    t.date "billdate"
    t.float "need_amount", limit: 53
    t.float "receive_amount", limit: 53
    t.float "need_receive", limit: 53
    t.float "bad_debt", limit: 53
    t.float "rest_receive", limit: 53
    t.float "bill_amount", limit: 53
    t.date "bill_due_date"
    t.date "bill_receive_date"
    t.text "customer"
    t.text "customer_jt"
    t.string "bill_type", limit: 45
    t.string "billno", limit: 200
    t.string "pmbillno", limit: 200
    t.string "fpbillno", limit: 45
    t.date "date"
  end

  create_table "SUB_COMPANY_NEED_RECEIVE_SIGN_DETAIL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "projectcode", limit: 45
    t.text "projectname"
    t.string "salescontractcode", limit: 45
    t.text "salescontractname"
    t.text "businessdirectorname"
    t.text "firstpartyname"
    t.string "orgcode_sum", limit: 45
    t.string "orgname_sum", limit: 45
    t.string "orgcode", limit: 45
    t.string "orgname", limit: 45
    t.string "deptcode_sum", limit: 45
    t.string "deptname_sum", limit: 45
    t.string "deptcode", limit: 45
    t.string "deptname", limit: 45
    t.float "amounttotal"
    t.float "sign_receive"
    t.datetime "contracttime"
    t.text "contractpropertyname"
    t.float "overamount"
    t.float "kpmoney"
    t.float "tpmoney"
    t.float "collectionamount"
    t.float "accneedreceive"
    t.datetime "collectiondate"
    t.date "date", null: false
    t.integer "need_hide", limit: 1
    t.index ["date"], name: "idx_sub_company_need_receive_sign_detail_date"
  end

  create_table "SUB_COMPANY_NEED_RECEIVE_UNSIGN_DETAIL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "projectitemcode"
    t.text "projectitemname"
    t.text "projectmanagername"
    t.string "orgcode_sum", limit: 45
    t.string "orgname_sum", limit: 45
    t.string "orgcode", limit: 45
    t.string "orgname", limit: 45
    t.string "deptcode_sum", limit: 45
    t.string "deptname_sum", limit: 45
    t.string "deptcode", limit: 45
    t.string "deptname", limit: 45
    t.float "unsign_receive", limit: 53
    t.float "predictamount", limit: 53
    t.date "fdate"
    t.datetime "createddate"
    t.date "mintimecardfill"
    t.integer "days_to_mintimecardfill"
    t.string "projectstatus", limit: 45
    t.date "date"
    t.integer "need_hide", limit: 1
  end

  create_table "SUB_COMPANY_REAL_RATE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "salescontractcode", limit: 20
    t.text "salescontractname"
    t.datetime "filingtime"
    t.string "projectitemcode", limit: 20
    t.text "projectitemname"
    t.datetime "createddate"
    t.string "orgcode_sum", limit: 20
    t.string "orgcode", limit: 20
    t.string "deptcode_sum", limit: 20
    t.string "deptcode", limit: 20
    t.string "specialty", limit: 20
    t.float "deptvalue", limit: 53
    t.float "sumvalue_nc", limit: 53
    t.float "sumvalue_change_nc", limit: 53
    t.float "realamount_nc", limit: 53
    t.float "sumvalue_now", limit: 53
    t.float "sumvalue_change_now", limit: 53
    t.float "realamount_now", limit: 53
    t.string "contractstatuscn", limit: 20
    t.string "projectstatuscn", limit: 20
    t.date "date"
  end

  create_table "SUB_COMPANY_REAL_RATE_SUM", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "orgcode_sum", limit: 20
    t.string "orgcode", limit: 20
    t.string "deptcode_sum", limit: 20
    t.string "deptcode", limit: 20
    t.date "date"
    t.float "sumvalue_change_nc", limit: 53
    t.float "realamount_nc", limit: 53
    t.float "trans_nc", limit: 53
    t.float "sumvalue_change_now", limit: 53
    t.float "realamount_now", limit: 53
    t.float "trans_now", limit: 53
  end

  create_table "SUB_COMPANY_REAL_RECEIVE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "orgcode_sum"
    t.text "orgcode"
    t.text "deptcode_sum"
    t.text "deptcode"
    t.date "realdate"
    t.float "real_receive", limit: 53
    t.float "trans_value", limit: 53
    t.float "total", limit: 53
    t.float "cumtotal", limit: 53
    t.float "belongmarketfee", limit: 53
    t.float "clientfeeorgsettle", limit: 53
    t.float "marketfeechange", limit: 53
    t.float "markettotal", limit: 53
    t.float "cummarkettotal", limit: 53
  end

  create_table "SUB_COMPANY_REAL_RECEIVE_CHANGE_DETAIL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "projectitemcode", limit: 45
    t.datetime "approvedate"
    t.string "orgcode_sum", limit: 45
    t.string "orgname_sum", limit: 200
    t.string "orgcode", limit: 45
    t.string "orgname", limit: 200
    t.string "deptcode_sum", limit: 45
    t.string "deptname_sum", limit: 200
    t.string "deptcode", limit: 45
    t.string "deptname", limit: 200
    t.float "trans_value", limit: 53
    t.string "adjusttype", limit: 45
  end

  create_table "SUB_COMPANY_REAL_RECEIVE_DETAIL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "projectcode"
    t.text "projectname"
    t.text "contractcode"
    t.text "salescontractname"
    t.text "orgcode_sum"
    t.text "orgname_sum"
    t.text "orgcode"
    t.text "orgname"
    t.text "deptcode_sum"
    t.text "deptname_sum"
    t.text "deptcode"
    t.text "deptname"
    t.float "real_receive", limit: 53
    t.date "realdate"
  end

  create_table "SUB_COMPANY_REAL_RECEIVE_MARKETFEE_DETAIL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "contractcode"
    t.text "contractname"
    t.float "collectionamount", limit: 53
    t.text "marketcomcode_sum"
    t.text "marketcomcode"
    t.text "marketdepartmentcode_sum"
    t.text "marketdepartmentcode"
    t.float "belongmarketfee", limit: 53
    t.text "clientmaintenancecomcode_sum"
    t.text "clientmaintenancecomcode"
    t.text "clientmaintenancedeptcode_sum"
    t.text "clientmaintenancedeptcode"
    t.float "clientfeeorgsettle", limit: 53
    t.date "confirmdate"
  end

  create_table "SUB_COMPANY_REAL_RECEIVE_ORIGIN", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "orgcode_sum"
    t.text "orgcode"
    t.text "deptcode_sum"
    t.text "deptcode"
    t.datetime "realdate"
    t.float "real_receive", limit: 53
    t.float "trans_value", limit: 53
    t.float "total", limit: 53
    t.float "belongmarketfee", limit: 53
    t.float "clientfeeorgsettle", limit: 53
    t.float "marketfeechange", limit: 53
    t.float "markettotal", limit: 53
    t.float "cumtotal", limit: 53
    t.float "cummarkettotal", limit: 53
  end

  create_table "TH_CALENDAR", primary_key: "datestamp", id: :date, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "iswork", limit: 10
    t.bigint "datetype"
    t.text "remark"
  end

  create_table "TH_DEPTPLANVALUE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "id"
    t.text "bizorgcode"
    t.text "createdbizorgcode"
    t.datetime "createddate"
    t.text "createdorgcode"
    t.text "creatorcode"
    t.bigint "dataversion"
    t.text "orgcode"
    t.text "redactorcode"
    t.text "redatebizorgcode"
    t.datetime "redatedate"
    t.text "redateorgcode"
    t.text "remark"
    t.text "status"
    t.text "businessdepartmentscode"
    t.text "businessdepartmentsname"
    t.text "businessltdcode"
    t.text "businessltdname"
    t.text "clientbouns"
    t.text "contractcategoryname"
    t.text "contractpropertyname"
    t.text "contractstatus"
    t.text "contractstatusname"
    t.text "deptvalue"
    t.text "filingtime"
    t.text "heji"
    t.text "marketbouns"
    t.text "professioncomcode"
    t.text "professioncomname"
    t.text "professiondeptcode"
    t.text "professiondeptname"
    t.text "salescontractcode"
    t.text "salescontractname"
    t.date "savedate"
    t.text "realamounttotal"
  end

  create_table "TH_RP_CRM_SACONTRACT", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "id"
    t.text "bizorgcode"
    t.text "createdbizorgcode"
    t.datetime "createddate"
    t.text "createdorgcode"
    t.text "creatorcode"
    t.bigint "dataversion"
    t.text "orgcode"
    t.text "redactorcode"
    t.text "redatebizorgcode"
    t.datetime "redatedate"
    t.text "redateorgcode"
    t.text "remark"
    t.text "status"
    t.text "amounttotal"
    t.text "area"
    t.text "areaname"
    t.text "belongcompanyname"
    t.text "businessdepartmentscode"
    t.text "businessdepartmentsname"
    t.text "businessdirectorname"
    t.text "businessltdcode"
    t.text "businessltdname"
    t.text "checktime"
    t.text "city"
    t.text "cityname"
    t.text "contractcategory"
    t.text "contractcategorycnname"
    t.text "contractproperty"
    t.text "contractpropertycnname"
    t.text "contractstatus"
    t.text "contractstatuscnname"
    t.text "contracttime"
    t.text "filingtime"
    t.text "firstpartyname"
    t.text "operationgenre"
    t.text "operationgenrename"
    t.text "partybname"
    t.text "proareacode"
    t.text "projectbigstage"
    t.text "projectbigstagename"
    t.text "projectcode"
    t.text "projectname"
    t.text "projecttype"
    t.text "projecttypename"
    t.text "provincecode"
    t.text "provincename"
    t.text "realamounttotal"
    t.text "salescontractcode"
    t.text "salescontractname"
    t.date "savedate"
    t.text "scalearea"
    t.text "scaletype"
    t.text "scaletypecnname"
    t.text "shardconamount"
    t.text "stage"
    t.text "stagename"
    t.text "virtual"
    t.text "clientsshort"
  end

  create_table "TRACK_CONTRACT", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "orgcode", limit: 20
    t.string "deptcode", limit: 20
    t.float "contractconvert", limit: 53
    t.float "convertrealamount", limit: 53
    t.date "date"
    t.string "orgcode_sum", limit: 45
    t.string "deptcode_sum", limit: 45
    t.index ["id"], name: "id_UNIQUE", unique: true
  end

  create_table "TRACK_CONTRACT_OPPORTUNITY_DETAIL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "opportunitycode", limit: 20
    t.text "opportunityname"
    t.text "opportunitycontent"
    t.datetime "traceassigndate"
    t.float "contractamount", limit: 53
    t.float "successrate", limit: 53
    t.float "contractconvert", limit: 53
    t.text "cnname"
    t.string "orgcode", limit: 20
    t.string "deptcode", limit: 20
    t.text "businessdirectorname"
    t.date "date"
    t.string "orgcode_sum", limit: 45
    t.string "deptcode_sum", limit: 45
  end

  create_table "TRACK_CONTRACT_SIGNING_DETAIL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "salescontractcode"
    t.text "projectcode"
    t.text "salescontractname"
    t.datetime "contracttime"
    t.float "realamounttotal", limit: 53
    t.float "convertrealamount", limit: 53
    t.bigint "versions"
    t.string "orgcode", limit: 20
    t.string "deptcode", limit: 20
    t.text "businessdirectorname"
    t.text "status"
    t.date "date"
    t.string "orgcode_sum", limit: 45
    t.string "deptcode_sum", limit: 45
  end

  create_table "V_RCONTRACTVALUESETTLEMENTDET_SAVE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "projectcode"
    t.text "projectname"
    t.text "contractcode"
    t.text "salescontractname"
    t.text "contractcategory"
    t.text "contractproperty"
    t.text "maincontractcode"
    t.text "bigstage1"
    t.text "firstpartyname"
    t.text "partybcode"
    t.text "partybid"
    t.text "partybname"
    t.text "businessdirector"
    t.text "businesspatronn"
    t.text "businessltdname"
    t.text "businessltdcode"
    t.text "businessdepartmentsname"
    t.text "businessdepartmentscode"
    t.text "projectmanagerid"
    t.text "seprojectmanagerid"
    t.text "firstproleaderid"
    t.text "secondproleaderid"
    t.text "secondproleadercode"
    t.text "secondproleadername"
    t.text "businesstype"
    t.text "operationgenre"
    t.text "projectcategory"
    t.text "projecttype"
    t.text "bigstage"
    t.text "stage"
    t.text "projectstage"
    t.text "projectbigstage"
    t.float "amounttotal", limit: 53
    t.float "realamounttotal", limit: 53
    t.float "shardconamount", limit: 53
    t.text "collectionterms"
    t.text "collectiontermcode"
    t.text "collectiondate"
    t.float "collectionamount", limit: 53
    t.text "iscashflow"
    t.text "linetype"
    t.text "adjustdate"
    t.text "realdate"
    t.datetime "bonusperiod"
    t.float "taxrate", limit: 53
    t.float "depositamount", limit: 53
    t.float "reservefundpercent", limit: 53
    t.float "percent", limit: 53
    t.float "shardamount", limit: 53
    t.float "amount", limit: 53
    t.text "itemcode"
    t.text "projectpaname"
    t.text "projectpacode"
    t.text "itemname"
    t.text "specialtycode"
    t.text "specialty"
    t.text "cmp"
    t.text "cmpcode"
    t.text "cmpid"
    t.text "deptid"
    t.text "dept"
    t.text "deptcode"
    t.float "sumamount", limit: 53
    t.text "yesno"
    t.text "yorn"
    t.text "squaredate"
    t.float "bonusratio", limit: 53
    t.float "bonus", limit: 53
    t.text "confirmstatus"
    t.text "confirmstatusname"
    t.datetime "confirmdate"
    t.text "billingtime"
    t.text "wnsk_flag"
    t.text "billingtxt"
    t.text "billingcode"
    t.text "savedate"
    t.datetime "refreshdate"
  end

  create_table "V_TH_CRM_RPOPPORTUNITY", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "projectcode"
    t.text "projectname"
    t.text "opportunitycode"
    t.text "opportunityname"
    t.datetime "createddate"
    t.text "coworkapproach"
    t.text "coworkapproachname"
    t.text "yesorno"
    t.text "mainbusinesstype"
    t.text "mainbusinesstypename"
    t.text "otherbusinesstypename"
    t.text "servicestage"
    t.text "contractdate"
    t.float "contractamount", limit: 53
    t.float "successrate", limit: 53
    t.float "contractconvert", limit: 53
    t.text "designstatus"
    t.text "opportunitystatus"
    t.text "opportunitystatusname"
    t.text "businessdirector"
    t.text "businessdirectorcode"
    t.text "businessdirectorname"
    t.text "businessdirectororg"
    t.text "businessdirectororgid"
    t.text "businessdirectororgname"
    t.text "businessdirectordept"
    t.text "businessdirectordeptid"
    t.text "businessdirectordeptname"
    t.text "traceassigndate"
    t.text "redatedate"
    t.text "provincename"
    t.text "cityname"
    t.text "belongarea"
    t.text "marketclass"
    t.text "areatype"
    t.float "areaarchitecture", limit: 53
    t.float "areazd", limit: 53
    t.float "volume", limit: 53
    t.text "belongcompanyname"
    t.text "clientsshort"
    t.text "iscontract"
    t.datetime "realcontractdate"
  end

  create_table "V_TH_DEPTMONEYFLOW_SAVE", primary_key: ["checkdate", "deptid"], charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "compid", limit: 200
    t.string "comp", limit: 200
    t.string "compname", limit: 200
    t.string "deptid", limit: 200, null: false
    t.string "dept", limit: 200
    t.string "deptname", limit: 200
    t.date "checkdate", null: false
    t.float "openingmoney", limit: 53
    t.float "nextbonusamount", limit: 53
    t.float "nextamount", limit: 53
    t.float "covertmoney", limit: 53
    t.float "nexthrpaymoney", limit: 53
    t.float "nextdeptprocost", limit: 53
    t.float "nextdeptcost", limit: 53
    t.float "changemoney", limit: 53
    t.float "allocationmoney", limit: 53
    t.float "deptmoney", limit: 53
    t.float "allowancemoney", limit: 53
    t.float "allowancesetmoney", limit: 53
    t.float "endmoney", limit: 53
    t.datetime "refresh_date"
  end

  create_table "V_TH_DEPTMONEYFLOW_SAVE1", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "compid", limit: 200
    t.string "comp", limit: 200
    t.string "compname", limit: 200
    t.string "deptid", limit: 200, null: false
    t.string "dept", limit: 200
    t.string "deptname", limit: 200
    t.date "checkdate", null: false
    t.float "openingmoney", limit: 53
    t.float "nextbonusamount", limit: 53
    t.float "nextamount", limit: 53
    t.float "covertmoney", limit: 53
    t.float "nexthrpaymoney", limit: 53
    t.float "nextdeptprocost", limit: 53
    t.float "nextdeptcost", limit: 53
    t.float "changemoney", limit: 53
    t.float "allocationmoney", limit: 53
    t.float "deptmoney", limit: 53
    t.float "allowancemoney", limit: 53
    t.float "allowancesetmoney", limit: 53
    t.float "endmoney", limit: 53
    t.datetime "refresh_date"
  end

  create_table "V_TH_NEWMAPINFO", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "id"
    t.text "marketinfoname"
    t.datetime "createddate"
    t.text "projectframename"
    t.float "scalearea", limit: 53
    t.text "province"
    t.text "company"
    t.text "projecttype"
    t.text "projecttype1"
    t.text "bigstage"
    t.text "developercompanyname"
    t.text "assistthedepartment"
    t.text "trackingdistributiondate"
    t.text "buildinggenrename"
    t.text "coordinate"
    t.text "maindeptname"
    t.text "businessdirectorname"
    t.text "maindeptnamedet"
    t.text "tracestate"
    t.text "ischecked"
  end

  create_table "V_TH_NEWMAPINFO_REL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "projectcode"
    t.text "docname"
    t.text "address"
  end

  create_table "V_TH_RP_CRM_SACONTRACT", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "orgcode"
    t.text "redatedate"
    t.text "bizorgcode"
    t.text "id"
    t.text "businessdirector"
    t.text "businesspatronn"
    t.text "nameid"
    t.text "businessltd"
    t.text "businessltdcode"
    t.text "businessdepartments"
    t.text "businessdepartmentscode"
    t.text "manufacturingltd"
    t.text "manufacturingdepartment"
    t.text "regionalism"
    t.text "projectcode"
    t.text "projectname"
    t.text "salescontractcode"
    t.text "salescontractname"
    t.text "contractstatus"
    t.text "contractstatuscnname"
    t.text "contractcategory"
    t.text "contractcategorycnname"
    t.text "contractproperty"
    t.text "contractpropertycnname"
    t.text "virtual"
    t.text "virtualcnname"
    t.text "maincontractcode"
    t.text "firstpartyname"
    t.text "partybname"
    t.float "amounttotal", limit: 53
    t.float "shardconamount", limit: 53
    t.float "realamounttotal", limit: 53
    t.text "scaletype"
    t.text "scaletypecnname"
    t.float "scalearea", limit: 53
    t.text "conprovidecode"
    t.text "conprovidename"
    t.text "isprovideok"
    t.text "area"
    t.text "provincecode"
    t.text "provincename"
    t.text "city"
    t.text "cityname"
    t.text "proareacode"
    t.text "areaname"
    t.date "contracttime"
    t.date "checktime"
    t.date "filingtime"
    t.text "businessltdname"
    t.text "businessdepartmentsname"
    t.text "manufacturingltdname"
    t.text "manufacturingdepartmentname"
    t.text "businessdirectorname"
    t.text "stagename"
    t.text "stage"
    t.text "projectbigstage"
    t.text "projectbigstagename"
    t.text "operationgenre"
    t.text "operationgenrename"
    t.text "projecttype"
    t.text "projecttypename"
    t.text "belongcompanyname"
    t.text "clientsshort"
  end

  create_table "V_TH_RP_MARKETSETTLEDET_SAVE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "id"
    t.text "projectcode"
    t.text "projectname"
    t.text "contractcode"
    t.text "contractname"
    t.text "settlementstatus"
    t.text "collectiondate"
    t.float "collectionamount", limit: 53
    t.float "amountdistribution", limit: 53
    t.text "adjustdate"
    t.text "businesstype"
    t.text "projecttype"
    t.text "partybcode"
    t.text "partybid"
    t.text "partybname"
    t.text "firstparty"
    t.text "firstpartycode"
    t.text "firstpartyname"
    t.text "contractlinecode"
    t.text "businesstypename"
    t.text "projecttypename"
    t.text "marketcomp"
    t.text "marketcomcode"
    t.text "marketcomname"
    t.text "marketdepartmentcode"
    t.text "marketdepartment"
    t.text "marketdepartmentname"
    t.float "belongmarketfee", limit: 53
    t.text "clientmaintenancecomcode"
    t.text "clientmaintenancecomid"
    t.text "clientmaintenancecomname"
    t.text "clientmaintenancedeptcode"
    t.text "clientmaintenancedeptid"
    t.text "clientmaintenancedeptname"
    t.float "marketfeetotal", limit: 53
    t.float "marketfeesettletotal", limit: 53
    t.float "marketfeesettle", limit: 53
    t.text "businessdirector"
    t.text "filingtime"
    t.float "taxrate", limit: 53
    t.float "realamounttotal", limit: 53
    t.float "marketfeerate", limit: 53
    t.float "clientfeeorgsettle", limit: 53
    t.float "clientfeerate", limit: 53
    t.float "clientfeetotal", limit: 53
    t.text "namename"
    t.text "businessdirectorid"
    t.text "businessdirectorname"
    t.text "businesspatronn"
    t.text "businesspatronnname"
    t.text "nameid"
    t.text "confirmstatus"
    t.text "confirmstatusname"
    t.text "billingtime"
    t.text "wnsk_flag"
    t.text "yorn"
    t.datetime "confirmdate"
    t.text "savedate"
    t.datetime "refreshdate"
    t.string "iscashflow", limit: 10, default: "Y"
  end

  create_table "V_TH_SACONTRACT", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "contractcategory"
    t.text "contractcategoryname"
    t.text "contractproperty"
    t.text "contractpropertyname"
    t.text "maincontractcode"
    t.text "maincontractname"
    t.text "sourcebusinesscode"
    t.text "sourcebusinessname"
    t.text "projectcode"
    t.text "projectname"
    t.text "salescontractid"
    t.text "salescontractcode"
    t.text "salescontractname"
    t.text "salescontractshort"
    t.text "contractstatus"
    t.text "contractstatusname"
    t.text "purchasestatus"
    t.text "purchasestatusname"
    t.float "amounttotal", limit: 53
    t.float "shardconamount", limit: 53
    t.float "realamounttotal", limit: 53
    t.text "currency"
    t.text "virtual"
    t.text "virtualname"
    t.float "grossnoboth", limit: 53
    t.float "grossdepartment", limit: 53
    t.float "grossall", limit: 53
    t.float "rate", limit: 53
    t.text "scaletype"
    t.text "scaletypename"
    t.float "scalearea", limit: 53
    t.text "firstparty"
    t.text "firstpartyid"
    t.text "firstpartyname"
    t.text "partyb"
    t.text "partybid"
    t.text "partybname"
    t.text "partyc"
    t.text "partycname"
    t.text "constructionunit"
    t.text "businessltd"
    t.text "businessltdid"
    t.text "businessltdname"
    t.text "businessdepartments"
    t.text "businessdepartmentsid"
    t.text "businessdepartmentsname"
    t.text "businessdirector"
    t.text "businessdirectorname"
    t.text "businesspatronn"
    t.text "businesspatronnname"
    t.text "manufacturingltd"
    t.text "manufacturingltdid"
    t.text "manufacturingltdname"
    t.text "manufacturingdepartment"
    t.text "manufacturingdepartmentid"
    t.text "manufacturingdepartmentname"
    t.text "checktime"
    t.datetime "filingtime"
    t.datetime "contracttime"
    t.datetime "finishtime"
    t.datetime "terminaltime"
    t.text "bankaccount"
    t.text "bankdeposit"
    t.bigint "versions"
    t.datetime "createddate"
    t.text "refuse"
    t.datetime "redatedate"
    t.float "discounttotal", limit: 53
  end

  create_table "V_TH_SACONTRACTCOLLPLAN", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "salescontractid"
    t.text "collratio"
    t.float "collmoney", limit: 53
    t.text "paymentsign"
    t.text "contcollplan"
  end

  create_table "V_TH_SACONTRACTPRICE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "operationgenre"
    t.text "operationgenrename"
    t.text "projectitemgenre"
    t.text "projectitemgenrename"
    t.text "buildinggenre"
    t.text "buildinggenrename"
    t.text "projectbigstage"
    t.text "bigstagename"
    t.text "stage"
    t.text "stagename"
    t.text "major"
    t.text "isneedcheck"
    t.text "istargetstage"
    t.float "scale", limit: 53
    t.float "univalence", limit: 53
    t.text "unitsname"
    t.float "discountprice", limit: 53
    t.text "settlementrate"
    t.text "units"
    t.float "subtotal", limit: 53
    t.text "salescontractid"
    t.datetime "createddate"
    t.datetime "redatedate"
  end

  create_table "V_TH_SALESFILES", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "salescontractid"
    t.text "enclosurename"
    t.text "attachmentaddress"
    t.datetime "uploadtime"
  end

  create_table "WEATHER_RECORD", primary_key: "index", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "地点"
    t.date "日期"
    t.text "时间"
    t.float "当天最高温度"
    t.text "天气"
    t.float "当前温度"
    t.float "当前湿度"
    t.text "预计明日天气"
    t.index ["index"], name: "index_UNIQUE", unique: true
  end

  create_table "WORKHOURS_LABEL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "gxname"
    t.text "profession"
  end

  create_table "WORK_HOURS_COUNT_COMBINE", primary_key: ["date", "ncworkno"], charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "userid", limit: 100
    t.string "username", limit: 100
    t.string "ncworkno", limit: 100, null: false
    t.date "date", null: false
    t.float "realhours", limit: 53
    t.float "type1", limit: 53
    t.float "type2", limit: 53
    t.float "type22", limit: 53
    t.float "type24", limit: 53
    t.float "type4", limit: 53
    t.text "summary"
    t.float "needhours", limit: 53
    t.string "profession", limit: 100
    t.string "orgcode_sum", limit: 100
    t.string "orgcode", limit: 100
    t.string "deptcode_sum", limit: 100
    t.string "deptcode", limit: 100
    t.integer "iswork", limit: 1
    t.index ["date", "orgcode"], name: "idx_work_hours_count_combine_date"
  end

  create_table "WORK_HOURS_COUNT_DETAIL_DEPT_OLD", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "orgcode_sum", limit: 45
    t.string "orgname_sum", limit: 45
    t.string "orgcode", limit: 45
    t.string "orgname", limit: 45
    t.string "deptcode_sum", limit: 45
    t.string "deptname_sum", limit: 45
    t.string "deptcode", limit: 45
    t.string "deptname", limit: 45
    t.datetime "date"
    t.float "date_need", limit: 53
    t.float "date_real", limit: 53
    t.float "blue_print_need", limit: 53
    t.float "blue_print_real", limit: 53
    t.float "construction_need", limit: 53
    t.float "construction_real", limit: 53
    t.float "fill_rate", limit: 53
    t.float "blue_print_rate", limit: 53
    t.float "construction_rate", limit: 53
  end

  create_table "WORK_HOURS_COUNT_DETAIL_STAFF_OLD", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "orgcode_sum", limit: 45
    t.string "orgname_sum", limit: 45
    t.string "orgcode", limit: 45
    t.string "orgname", limit: 45
    t.string "deptcode_sum", limit: 45
    t.string "deptname_sum", limit: 45
    t.string "deptcode", limit: 45
    t.string "deptname", limit: 45
    t.string "work_no", limit: 45
    t.string "user_name", limit: 45
    t.datetime "date"
    t.float "date_need", limit: 53
    t.float "date_real", limit: 53
    t.float "blue_print_need", limit: 53
    t.float "blue_print_real", limit: 53
    t.float "construction_need", limit: 53
    t.float "construction_real", limit: 53
    t.float "fill_rate", limit: 53
    t.float "blue_print_rate", limit: 53
    t.float "construction_rate", limit: 53
  end

  create_table "WORK_HOURS_COUNT_NEED_OLD", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "userid"
    t.text "username"
    t.text "ncworkno"
    t.datetime "date"
    t.float "dayhours", limit: 53
    t.text "orgcode_sum"
    t.text "orgcode"
    t.text "deptcode_sum"
    t.text "deptcode"
    t.text "profession"
  end

  create_table "WORK_HOURS_COUNT_ORG_OLD", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "orgcode_sum", limit: 45
    t.string "orgcode", limit: 45
    t.string "orgname_sum", limit: 45
    t.string "orgname", limit: 45
    t.datetime "date"
    t.bigint "date_need"
    t.float "date_real", limit: 53
    t.float "blue_print_need", limit: 53
    t.float "blue_print_real", limit: 53
    t.float "construction_need", limit: 53
    t.float "construction_real", limit: 53
    t.float "fill_rate", limit: 53
    t.float "blue_print_rate", limit: 53
    t.float "construction_rate", limit: 53
  end

  create_table "WORK_HOURS_COUNT_REAL_OLD", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.datetime "date"
    t.text "userid"
    t.text "username"
    t.text "ncworkno"
    t.bigint "type"
    t.text "prjno"
    t.float "hours", limit: 53
    t.text "orgcode_sum"
    t.text "orgcode"
    t.text "deptcode_sum"
    t.text "deptcode"
    t.text "profession"
  end

  create_table "WORK_HOURS_DAY_COUNT_DEPT", primary_key: ["date", "deptcode"], charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "orgcode_sum", limit: 100
    t.string "orgcode", limit: 100
    t.string "deptcode_sum", limit: 100
    t.string "deptcode", limit: 100, null: false
    t.date "date", null: false
    t.float "date_need", limit: 53
    t.float "date_real", limit: 53
    t.float "fill_rate", limit: 53
    t.float "work_need", limit: 53
    t.float "work_real", limit: 53
    t.float "work_rate", limit: 53
    t.float "blue_print_need", limit: 53
    t.float "blue_print_real", limit: 53
    t.float "blue_print_rate", limit: 53
    t.float "construction_need", limit: 53
    t.float "construction_real", limit: 53
    t.float "construction_rate", limit: 53
    t.float "others_need", limit: 53
    t.float "others_real", limit: 53
    t.float "others_rate", limit: 53
  end

  create_table "WORK_HOURS_DAY_COUNT_ORG", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "orgcode_sum"
    t.text "orgcode"
    t.datetime "date"
    t.float "date_need", limit: 53
    t.float "date_real", limit: 53
    t.float "work_need", limit: 53
    t.float "work_real", limit: 53
    t.float "blue_print_need", limit: 53
    t.float "blue_print_real", limit: 53
    t.float "construction_need", limit: 53
    t.float "construction_real", limit: 53
    t.float "others_need", limit: 53
    t.float "others_real", limit: 53
    t.float "fill_rate", limit: 53
    t.float "blue_print_rate", limit: 53
    t.float "construction_rate", limit: 53
    t.float "others_rate", limit: 53
    t.float "work_rate", limit: 53
  end

  create_table "WUHAN_DEPT_COMBINE", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "deptcode1"
    t.text "deptname1"
    t.text "orgcode1"
    t.text "orgname1"
    t.text "deptname2"
    t.text "deptcode2"
    t.text "orgcode2"
    t.text "orgname2"
  end

  create_table "YEAR_AVG_STAFF", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "orgcode", limit: 20
    t.string "deptcode", limit: 20
    t.date "f_month"
    t.float "date_x", limit: 53
    t.float "date_y", limit: 53
    t.float "avgamount", limit: 53
    t.string "deptcode_sum", limit: 20
    t.string "orgcode_sum", limit: 20
  end

  create_table "YEAR_AVG_STAFF_ALL", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "orgcode"
    t.text "deptcode"
    t.datetime "f_month"
    t.float "date_x", limit: 53
    t.float "date_y", limit: 53
    t.float "avgamount", limit: 53
    t.text "deptcode_sum"
    t.text "orgcode_sum"
  end

  create_table "YEAR_REPORT_HISTORY", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.bigint "year"
    t.bigint "month"
    t.string "year_month", limit: 50
    t.string "orgcode_sum", limit: 50
    t.string "orgcode", limit: 50
    t.float "contractamount", limit: 53
    t.float "deptvalue", limit: 53
    t.float "realamount", limit: 53
    t.float "avg_work_no", limit: 53
    t.float "avg_staff_no", limit: 53
    t.float "avg_work_no_sum", limit: 53
    t.float "avg_staff_no_sum", limit: 53
  end

  create_table "comment_on_project_item_codes", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "project_item_code"
    t.string "comment"
    t.date "record_month"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "comment_on_sales_contract_codes", charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.string "sales_contract_code", null: false
    t.string "comment", null: false
    t.date "record_month", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "crm_opportunity", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "id"
    t.text "bizorgcode"
    t.text "createdbizorgcode"
    t.datetime "createddate"
    t.text "createdorgcode"
    t.text "creatorcode"
    t.bigint "dataversion"
    t.text "orgcode"
    t.text "redactorcode"
    t.text "redatebizorgcode"
    t.datetime "redatedate"
    t.text "redateorgcode"
    t.text "remark"
    t.text "status"
    t.text "abberviation"
    t.float "area", limit: 53
    t.text "areatype"
    t.text "belongarea"
    t.text "businessdirector"
    t.text "businessdirectorid"
    t.text "businessdirectordept"
    t.text "businessdirectordeptid"
    t.text "businessdirectordeptname"
    t.text "businessdirectorname"
    t.text "businessdirectororg"
    t.text "businessdirectororgid"
    t.text "businessdirectororgname"
    t.float "contractamount", limit: 53
    t.float "contractconvert", limit: 53
    t.datetime "contractdate"
    t.text "coworkapproach"
    t.text "designstatus"
    t.datetime "finishdate"
    t.text "invbusiness"
    t.text "mainbusinesstype"
    t.text "marketclass"
    t.text "opportunitycode"
    t.text "opportunitycontent"
    t.text "opportunityname"
    t.text "opportunitystatus"
    t.text "otherbusinesstype"
    t.text "projectid"
    t.text "projectcode"
    t.text "projectname"
    t.text "refusereason"
    t.text "servicestage"
    t.text "sourcecluid"
    t.text "sourcecluecode"
    t.text "sourcecluename"
    t.float "successrate", limit: 53
    t.datetime "traceassigndate"
    t.float "volume", limit: 53
    t.text "yesorno"
    t.datetime "businessstartdate"
    t.datetime "entrustokdate"
    t.text "projecttype"
    t.text "isplan"
    t.text "projectbigstage"
    t.text "iscontract"
    t.datetime "realcontractdate"
  end

  create_table "cybros_dashboards", charset: "utf8mb4", collation: "utf8mb4_bin", comment: "管理驾驶舱", force: :cascade do |t|
    t.date "fill_at", comment: "数据填写日期"
    t.integer "current_employee_hc", comment: "现有人数"
    t.integer "average_employee_hc", comment: "平均人数"
    t.integer "this_month_foreign_recruits", comment: "本月外招人数"
    t.integer "this_month_departures", comment: "本月离职人数"
    t.integer "accumulative_foreign_recruits", comment: "累计外招人数"
    t.integer "accumulative_departures", comment: "累计离职人数"
    t.integer "estimated_onboard_in_month", comment: "预计当月入职人数"
    t.integer "turnover_rate", comment: "离职率"
    t.decimal "contract_amounts", precision: 10, comment: "生产合同额"
    t.decimal "predict_contracts", precision: 10, comment: "跟踪合同额"
    t.decimal "contract_amount_of_the_month", precision: 10, comment: "当月生产合同额"
    t.decimal "contract_amount_per_employee", precision: 10, comment: "全员人均生产合同额"
    t.decimal "contract_amount_per_worker", precision: 10, comment: "一线人均生产合同额"
    t.decimal "predict_contracts_per_employee", precision: 10, comment: "全员人均跟踪合同额"
    t.decimal "predict_contracts_per_worker", precision: 10, comment: "全员人均跟踪合同额"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "v_gcz_projectitem", id: false, charset: "utf8mb4", collation: "utf8mb4_bin", force: :cascade do |t|
    t.text "projectcode"
    t.text "projectitemdeptname"
    t.text "businesstypecnname"
  end

end
