# frozen_string_literal: true

module Bi
  class VCrmSacontractPolicy < BasePolicy
    class Scope < Scope
      def resolve
        return scope.none unless user.present?

        if user.admin? || user.chinese_name.in?(%w[王旭冉 王俐雯])
          scope.all
        else
          scope.none
        end
      end
    end
  end
end
