# frozen_string_literal: true

module Bi
  class HumanResourcePolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        ( user.roles.pluck(:hr_group_rt_reader).any? ||
          user.roles.pluck(:hr_subsidiary_rt_reader).any? ||
          user.roles.pluck(:hr_report_writer).any? ||
          (user.job_level.to_i >= 14 && user.position_title.include?('所长')) ||
          (user.job_level.to_i >= 13 && user.position_title.include?('管理副所长')) ||
          user.admin?)
    end
  end
end
