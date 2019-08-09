# frozen_string_literal: true

module Bi
  class BiLocalTimeRecord < ActiveRecord::Base
    self.abstract_class = true
    self.default_timezone = :local
    establish_connection :cybros_bi
  end
end
