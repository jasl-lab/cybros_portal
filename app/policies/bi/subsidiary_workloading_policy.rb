module Bi
  class SubsidiaryWorkloadingPolicy < ApplicationPolicy
    def show?
      true
    end

    def export?
      true
    end
  end
end
