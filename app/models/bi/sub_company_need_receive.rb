# frozen_string_literal: true

module Bi
  class SubCompanyNeedReceive < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = "SUB_COMPANY_NEED_RECEIVE"

    def self.all_month_names
      Bi::SubCompanyNeedReceive.order(date: :asc).pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end
  end
end
