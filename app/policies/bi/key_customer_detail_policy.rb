# frozen_string_literal: true

module Bi
  class KeyCustomerDetailPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? && (user.admin? \
        || user.roles.pluck(:large_customer_detail_viewser).any?)
    end
  end
end
