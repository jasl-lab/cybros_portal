class Department < ApplicationRecord
  has_many :department_users, dependent: :destroy
  has_many :users, through: :department_users

  def self.office_addresses
    ['上海市徐汇区中山西路1800号兆丰环球大厦',
     '上海市钦州北路1188号漕河泾科汇大厦',
     '上海市柳州路928号 百丽国际广场3楼',
     '上海市田州路159号',
     '上海市杨浦区杨树浦路1066号滨江国际广场2号楼']
  end
end
