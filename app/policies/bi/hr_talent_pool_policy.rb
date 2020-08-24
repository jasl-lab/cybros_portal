# frozen_string_literal: true

module Bi
  class HrTalentPoolPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? &&
        (user.roles.pluck(:hr_subsidiary_reader).any? ||
          (user.roles.pluck(:role_name).any? { |r| r == 'HR_所级管理者' }) || (user.roles.pluck(:role_name).any? { |r| r == 'HR_子公司总经理、董事长' }) ||
          user.admin?)
    end
  end
end
