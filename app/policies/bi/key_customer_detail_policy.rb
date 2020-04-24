# frozen_string_literal: true

module Bi
  class KeyCustomerDetailPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? && user.chinese_name == '方子雪'
    end
  end
end
