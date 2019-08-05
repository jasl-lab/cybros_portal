module Bi
  class ShRefreshRateDetail < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = "SH_REFRESH_RATE_DETAIL"

  end
end
