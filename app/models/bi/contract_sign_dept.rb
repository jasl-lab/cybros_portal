module Bi
  class ContractSignDept < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'CONTRACT_SIGN_DEPT'
  end
end
