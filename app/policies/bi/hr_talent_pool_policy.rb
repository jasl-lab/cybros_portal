# frozen_string_literal: true

module Bi
  class HrTalentPoolPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.roles.pluck(:hr_subsidiary_reader).any? || user.admin?)
    end
  end
end
