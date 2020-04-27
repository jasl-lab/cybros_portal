# frozen_string_literal: true

module Bi
  class SubsidiaryHumanResourcePolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.roles.pluck(:hr_group_rt_reader).any? || user.roles.pluck(:hr_subsidiary_rt_reader).any? || user.roles.pluck(:hr_report_writer).any? || user.admin?)
    end
  end
end
