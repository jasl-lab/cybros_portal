# frozen_string_literal: true

module Bi
  class AccountBusinessTargetDeptPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.admin?)
    end
  end
end