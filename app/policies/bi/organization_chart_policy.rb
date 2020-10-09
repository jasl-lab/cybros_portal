# frozen_string_literal: true

module Bi
  class OrganizationChartPolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.admin? && !user.chinese_name.in?(%w[许潇红])
    end
  end
end
