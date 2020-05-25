# frozen_string_literal: true

module Bi
  class BonusDistributionPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        ( user.chinese_name.in?(%w(郭颖杰)) ||
          user.admin?)
    end
  end
end
