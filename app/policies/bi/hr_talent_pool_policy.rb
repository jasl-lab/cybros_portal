# frozen_string_literal: true

module Bi
  class HrTalentPoolPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        ( user.roles.pluck(:hr_subsidiary_reader).any? ||
          (user.job_level.to_i >= 13 && user.position_titles.include?('管理副所长')) ||
          (user.job_level.to_i >= 14 && user.position_titles.include?('所长')) ||
          user.admin? )
    end
  end
end
