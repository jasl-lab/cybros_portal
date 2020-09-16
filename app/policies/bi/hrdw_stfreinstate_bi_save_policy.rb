# frozen_string_literal: true

module Bi
  class HrdwStfreinstateBiSavePolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.chinese_name.in?(%w[曾嵘 叶馨 过纯中]))
    end
  end
end
