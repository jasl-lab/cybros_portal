# frozen_string_literal: true

if @sas.present?
  json.contracts @sas do |item|
    json.id item.salescontractid # 合同ID
    json.code item.salescontractcode # 合同编号
    json.propertyName item.contractpropertyname # 合同类型
    json.title item.salescontractname # 合同名称
    json.amountTotal item.amounttotal # 合同总金额
    json.ltdName item.businessltdname # 商务责任公司
    json.deptsName item.businessdepartmentsname # 商务责任部门
  end
end

if @opportunities.present?
  json.opportunities @opportunities do |item|
    json.code item.opportunitycode # 商机编号
    json.title item.opportunityname # 商机名称
    json.status item.opportunitystatus # 商机跟踪状态
    json.traceAssignDate item.traceassigndate # 跟踪分配时间
    json.clientsName item.clientsname # 客户名称
    json.belongCompanyName item.belongcompanyname # 集团名称
    json.amount item.contractamount # 预计合同额
    json.directorOrgName item.businessdirectororgname # 商务责任公司
    json.directorDeptName item.businessdirectordeptname # 商务责任部门
    json.directorName item.businessdirectorname # 商务负责人
    json.clueProvideName item.clueprovidename # 线索提供人
    json.areaType item.areatype # 规模类型
    json.area item.area # 规模（㎡）
    json.mainBusinessTypeName item.mainbusinesstypename # 主业务类型
    json.projectType item.projecttype # 项目类型
    json.projectBigStage item.projectbigstage # 预计合同服务大阶段
    json.serviceStage item.servicestage # 预计合同服务小阶段
    json.coworkApproachName item.coworkapproachname # 合作接洽方式
    json.isPlan item.isplan # 是否为拿地方案
    json.contractDate item.contractdate # 计划签约时间
    json.successRate item.successrate # 成功率
    json.contractConvert item.contractconvert # 折算合同额
    json.finishDate item.finishdate # 跟踪完成时间
    json.refuseReason item.refusereason # 跟踪失败原因
  end
end
