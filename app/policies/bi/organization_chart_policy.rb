# frozen_string_literal: true

module Bi
  class OrganizationChartPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? && ( user.admin? \
        || user.roles.pluck(:org_viewer).any?
      )
    end
  end
end
