# frozen_string_literal: true

module Bi
  class SubsidiariesOperatingComparisonPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? && ( user.admin? || %w[蔡钦 聂琳 章静 崔立杰 柳玉进 王旭冉 王俐雯].include?(user.chinese_name) )
    end
  end
end
