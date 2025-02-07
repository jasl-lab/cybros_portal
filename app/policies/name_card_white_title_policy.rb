# frozen_string_literal: true

class NameCardWhiteTitlePolicy < ApplicationPolicy
  def index?
    user.admin? || user.chinese_name == '丁一'
  end

  def create?
    user.admin? || user.chinese_name == '丁一'
  end
end
