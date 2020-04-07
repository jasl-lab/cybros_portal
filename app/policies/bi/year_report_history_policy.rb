# frozen_string_literal: true

module Bi
  class YearReportHistoryPolicy < BasePolicy
    class Scope < Scope
      def resolve
        scope.all
      end
    end

    def show?
      user.present? && (user.admin? || %w[蔡钦 聂琳 章静 崔瑶].include?(user.chinese_name))
    end
  end
end
