# frozen_string_literal: true

module Bi
  class YearReportHistoryPolicy < BasePolicy
    def show?
      user.present? && user.admin?
    end
  end
end
