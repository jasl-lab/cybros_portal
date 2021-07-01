# frozen_string_literal: true

module Bi
  class KeyCustomerDetailPolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.admin? \
        || user.roles.pluck(:large_customer_detail_viewser).any? \
        || ((user.user_company_names & Role::CREATIVE_SECTION).any? && user&.position_title&.include?('总经理') && !user&.position_title&.include?('总经理助理')) \
        || (user.user_company_short_names.include?('上海天华') && (user&.position_title&.include?('管理副所长')))
    end
  end
end
