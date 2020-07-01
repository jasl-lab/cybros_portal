# frozen_string_literal: true

module Bi
  class OrganizationChartPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? && ( user.admin?)
      #年久失修 不给看 || user.roles.pluck(:org_viewer).any?
      
    end
  end
end
