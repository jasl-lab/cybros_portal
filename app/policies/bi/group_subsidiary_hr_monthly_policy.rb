# frozen_string_literal: true

module Bi
  class GroupSubsidiaryHrMonthlyPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        ( user.roles.pluck(:hr_subsidiary_reader).any? ||
          (user.job_level.to_i >= 17 && (user.position_title.include?('董事长') || user.position_title.include?('总经理'))) ||
          user.admin? )
    end
  end
end
