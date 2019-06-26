module Bi
  class ContractSignDetail < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'CONTRACT_SIGN_DETAIL'
  end
end
