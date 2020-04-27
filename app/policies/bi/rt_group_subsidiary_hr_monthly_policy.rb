# frozen_string_literal: true

module Bi
  class RtGroupSubsidiaryHrMonthlyPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.roles.pluck(:hr_subsidiary_rt_reader).any? || user.admin?)
    end
  end
end
