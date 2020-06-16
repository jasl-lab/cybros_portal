# frozen_string_literal: true

module Bi
  class HumanResourcePolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        ( user.roles.pluck(:hr_group_rt_reader).any? ||
          user.roles.pluck(:hr_subsidiary_rt_reader).any? ||
          user.roles.pluck(:hr_report_writer).any? ||
          (user.my_access_codes.any? do |access_code|
            job_level = access_code[4]
            title = access_code[3]
            job_level.to_i >= 14 && title.include?('所长')
           end
          ) ||
          (user.my_access_codes.any? do |access_code|
            job_level = access_code[4]
            title = access_code[3]
            job_level.to_i >= 13 && title.include?('管理副所长')
           end
           ) ||
          user.admin?)
    end
  end
end
