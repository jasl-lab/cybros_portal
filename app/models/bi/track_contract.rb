# frozen_string_literal: true

module Bi
  class TrackContract < BiLocalTimeRecord
    self.table_name = "TRACK_CONTRACT"

    def self.last_available_date
      order(date: :desc).first.date
    end

    def self.all_month_names
      order(date: :asc).pluck(:date).collect { |d| d.to_s(:month_and_year) }.uniq
    end

    def self.available_company_names(target_date)
      orgcodes = where(date: target_date).where("TRACK_CONTRACT.orgcode IS NOT NULL")
        .joins("LEFT JOIN ORG_ORDER on ORG_ORDER.org_code = TRACK_CONTRACT.orgcode")
        .order("ORG_ORDER.org_order DESC")
        .pluck(:orgcode).uniq
        .collect { |c| [Bi::OrgShortName.company_short_names_by_orgcode.fetch(c, c), c] }
    end
  end
end
