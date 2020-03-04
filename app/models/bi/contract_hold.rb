# frozen_string_literal: true

module Bi
  class ContractHold < BiLocalTimeRecord
    self.table_name = 'CONTRACT_HOLD'

    def self.all_month_names
      order(date: :desc).pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end

    def self.available_company_names(target_date)
      where(date: target_date).where('CONTRACT_HOLD.orgcode IS NOT NULL')
        .joins('LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = CONTRACT_HOLD.orgcode')
        .order('ORG_ORDER.org_order DESC')
        .pluck(:orgcode).uniq
        .collect { |c| [Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c), c] }
    end
  end
end
