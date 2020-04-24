# frozen_string_literal: true

module Bi
  class HrTalentPoolPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? && user.admin?
    end
  end
end
