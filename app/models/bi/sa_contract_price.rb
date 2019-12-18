# frozen_string_literal: true

module Bi
  class SaContractPrice < BiLocalTimeRecord
    self.table_name = "V_TH_SACONTRACTPRICE"

    def self.all_project_item_genre_name
      @_all_project_item_genre_name ||= ['所有'] + where.not(projectitemgenrename: nil).select(:projectitemgenrename).order(:projectitemgenrename).distinct.pluck(:projectitemgenrename)
    end
  end
end
