class Department < ApplicationRecord
  has_many :department_users, dependent: :destroy
  has_many :users, through: :department_users

  def self.office_addresses
    ['上海市徐汇区中山西路1800号 兆丰环球大厦',
     '上海市钦州北路1188号 漕河泾科汇大厦',
     '上海市柳州路928号 百丽国际广场3楼',
     '上海市杨浦区杨树浦路1066号 滨江国际广场2号楼',
     '北京市丰台区汽车博物馆东路2号院丰科中心2号楼五层']
  end
end
