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
  end
end
