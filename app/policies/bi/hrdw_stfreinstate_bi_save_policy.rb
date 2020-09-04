# frozen_string_literal: true

module Bi
  class HrdwStfreinstateBiSavePolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        ((user.roles.pluck(:role_name).any? { |r| r == 'HR_填报人' }) ||
          user.admin?)
    end
  end
end
