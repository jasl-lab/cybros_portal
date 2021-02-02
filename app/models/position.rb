# frozen_string_literal: true

class Position < ApplicationRecord
  belongs_to :department, optional: true
end
