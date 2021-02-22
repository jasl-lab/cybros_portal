# frozen_string_literal: true

class PositionUser < ApplicationRecord
  belongs_to :user
  belongs_to :position
  belongs_to :user_job_type, optional: true, class_name: 'SplitCost::UserJobType'

  delegate :name, to: :position, prefix: :position
end
