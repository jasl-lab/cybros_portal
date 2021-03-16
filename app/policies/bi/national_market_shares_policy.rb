# frozen_string_literal: true

module Bi
  class NationalMarketSharesPolicy < Struct.new(:user, :dashboard)
    def show?
      return false unless user.present?

      user.admin?
    end
  end
end
