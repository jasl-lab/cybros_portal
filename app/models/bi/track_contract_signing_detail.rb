# frozen_string_literal: true

module Bi
  class TrackContractSigningDetail < ApplicationRecord
    establish_connection :cybros_bi
    self.table_name = "TRACK_CONTRACT_SIGNING_DETAIL"
  end
end
