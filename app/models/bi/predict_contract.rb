module Bi
  class PredictContract < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'SH_PREDICT_CONTRACT'

    def self.last_avaiable_date
      order(date: :desc).first.date
    end
  end
end
