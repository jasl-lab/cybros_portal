# frozen_string_literal: true

module Bi
  class SubsidiariesOperatingComparisonPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? && ( user.admin? || user.roles.pluck(:group_report_viewer).any? )
    end
  end
end
