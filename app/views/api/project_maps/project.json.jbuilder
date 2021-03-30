# frozen_string_literal: true

json.code @project.id
json.title @project.marketinfoname
json.frameName @project.projectframename
json.traceState @project.tracestate
json.scaleArea @project.scalearea
json.province @project.province
json.city @project.company
json.amountTotal @project.amounttotal
json.businessTypeDeptnames @project.project_items.collect { |c| [c.businesstypecnname, c.projectitemdeptname].join(' | ') }.uniq
json.isBoutique !@project.isboutiqueproject.nil? && @project.isboutiqueproject > 0
json.items @project_items do |item|
  json.code item.projectitemcode # 项目编号
  json.title item.projectitemname # 项目名称
  json.isBoutique item.isboutiqueproject == '是' # 是否精品
  if item.isboutiqueproject == '是'
    response = HTTP.get("#{Rails.application.credentials.km_img_project_url!}/mt/GetProjectMapPicList?projectitemcode=#{item.projectitemcode}")
    result = JSON.parse response.body.to_s
    if result['data'].present?
      json.images result['data'].map { |it| it['projectpicurl'] }
    end
  end
  json.clientName item.clientname # 客户名称
  json.milestones item.milestonesname # 项目进展
  json.designendData item.designenddate # 设计完成时间
  json.address item.projectaddress # 项目地址
  json.comCode item.projectitemcomcode # 公司编号
  json.comName item.projectitemcomname # 公司全称
  json.comShortName item.projectitemcomshortname # 公司简称
  json.deptCode item.projectitemdeptcode # 部分编号
  json.deptName item.projectitemdeptname # 部门名称
  json.paName item.projectpaname # 主创/设总
  json.businessType item.businesstype # 项目类型编号
  json.businessTypeName item.businesstypename # 项目类型名称
  json.category item.projectcategory # 项目类别编号
  json.categoryName item.projectcategoryname # 项目类别名称
  json.privince item.provincename # 省
  json.city item.cityname # 市
  json.coordinate item.coordinate # 经纬度
  json.bigStage item.projectbigstage # 项目阶段编号
  json.bigStageName item.projectbigstagename # 项目阶段名称
  json.auditStatus item.projectresultsauditstatus # 项目审核阶段
end
