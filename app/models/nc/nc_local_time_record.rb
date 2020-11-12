# frozen_string_literal: true

module Nc
  class NcLocalTimeRecord < ActiveRecord::Base
    self.abstract_class = true
    self.default_timezone = :local
    establish_connection :nc_uap
  end
end
