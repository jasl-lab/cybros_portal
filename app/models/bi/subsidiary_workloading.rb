module Bi
  class SubsidiaryWorkloading < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'SUBSIDIARY_WORKLOADINGS'
  end
end
