# frozen_string_literal: true

module Hrdw
  class HrdwLocalTimeRecord < ActiveRecord::Base
    self.abstract_class = true
    self.default_timezone = :local
    establish_connection :bi_hrdw
  end
end
