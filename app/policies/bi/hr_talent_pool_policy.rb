# frozen_string_literal: true

module Bi
  class HrTalentPoolPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        ( user.roles.pluck(:hr_subsidiary_reader).any? ||
          (user.job_level.to_i >= 17 && (user.position_title.include?('董事长') || user.position_title.include?('总经理'))) ||
          (user.job_level.to_i >= 13 && user.position_title.include?('所长')) ||
          user.admin? )
    end
  end
end
