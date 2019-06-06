module Bi
  class SubsidiaryWorkloading < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'SUBSIDIARY_WORKLOADINGS'

    def self.all_month_names
      @all_month_names ||= Bi::SubsidiaryWorkloading.pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
