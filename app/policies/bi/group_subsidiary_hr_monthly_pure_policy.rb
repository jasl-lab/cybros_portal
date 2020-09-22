# frozen_string_literal: true

module Bi
  class GroupSubsidiaryHrMonthlyPurePolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        ( user.roles.pluck(:role_name).any? { |r| r.in?(%w[HR_人力资源报表责任人 HR_IT和人力管理员 HR_填报人]) } || 
        	user.admin? )
    end
  end
end
