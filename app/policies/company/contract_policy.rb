# frozen_string_literal: true

module Company
  class ContractPolicy < ApplicationPolicy
    def index?
      user&.admin?
    end
  end
end
