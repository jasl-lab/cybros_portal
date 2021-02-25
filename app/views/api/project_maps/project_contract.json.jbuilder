# frozen_string_literal: true

json.id @sc.salescontractid # 合同ID
json.code @sc.salescontractcode # 合同编号
json.title @sc.salescontractname # 合同名称
json.statusName @sc.contractstatusname # 合同状态
json.amountTotal @sc.amounttotal # 合同金额
json.shardconAmount @sc.shardconamount # 切分合同额
json.realAmountTotal @sc.realamounttotal # 实际合同额
json.ltdName @sc.businessltdname # 商务责任公司
json.deptsName @sc.businessdepartmentsname # 商务责任部门
json.directorName @sc.businessdirectorname # 商务负责人
json.categoryName @sc.contractcategoryname # 合同类型
json.propertyName @sc.contractpropertyname # 合同性质
json.scaleTypeName @sc.scaletypename # 规模类型
json.scaleArea @sc.scalearea # 规模面积（平方米）
json.firstPartyName @sc.firstpartyname # 甲方名称
json.partybName @sc.partybname # 乙方名称
json.prices @sc.prices do |item| # 分项单价
  json.operationGenreName item.operationgenrename
  json.buildingGenreName item.buildinggenrename
  json.bigStageName item.bigstagename
  json.univalence item.univalence
  json.scale item.scale
end
json.payPlans @sc.pay_plans do |item| # 付款条件
  json.contCollPlan item.contcollplan
  json.collRatio item.collratio
  json.collMoney item.collmoney
end
json.files @sc.files do |item| # 合同附件
  json.title item.enclosurename
  json.url item.attachmentaddress
end
