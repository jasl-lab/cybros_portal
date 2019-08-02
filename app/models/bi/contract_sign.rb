# frozen_string_literal: true

module Bi
  class ContractSign < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = "CONTRACT_SIGN"

    def self.all_month_names
      @all_month_names ||= Bi::ContractSign.order(date: :asc).pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
