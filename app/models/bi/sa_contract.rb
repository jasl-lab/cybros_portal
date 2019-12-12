# frozen_string_literal: true

module Bi
  class SaContract < BiLocalTimeRecord
    self.table_name = "V_TH_SACONTRACT"

    has_many :prices, class_name: "Bi::SaContractPrice", primary_key: :salescontractid, foreign_key: :salescontractid
  end
end
