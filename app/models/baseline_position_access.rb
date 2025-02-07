# frozen_string_literal: true

class BaselinePositionAccess < ApplicationRecord
  enum contract_map_access: %i[no_access project_detail_with_download view_project_details view_project_only]
  has_many :positions, foreign_key: :b_postcode, primary_key: :b_postcode
end
