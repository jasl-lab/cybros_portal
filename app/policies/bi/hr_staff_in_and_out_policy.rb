# frozen_string_literal: true

module Bi
  class HrStaffInAndOutPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.admin?)
    end
  end
end