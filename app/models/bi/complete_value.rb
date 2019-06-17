module Bi
  class CompleteValue < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = 'COMPLETE_VALUE'

    def self.all_month_names
      @all_month_names ||= Bi::CompleteValue.order(date: :asc).pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
