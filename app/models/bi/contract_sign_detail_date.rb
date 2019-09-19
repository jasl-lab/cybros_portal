# frozen_string_literal: true

module Bi
  class ContractSignDetailDate < BiLocalTimeRecord
    self.table_name = "CONTRACT_SIGN_DETAIL_DATE"

    def self.all_month_names
      order(contracttime: :asc).pluck(:contracttime).collect { |d| d.to_s(:month_and_year) }.uniq
    end

    def self.all_org_long_names(last_available_date)
      where(date: last_available_date).select(:orgname).distinct.pluck(:orgname)
    end

    def self.last_available_date(end_of_month)
      available_date = where("date <= ?", end_of_month).order(date: :desc).first&.date
      available_date = order(date: :desc).first.date if available_date.nil?
      available_date
    end
  end
end
