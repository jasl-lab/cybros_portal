# frozen_string_literal: true

module Bi
  class ContractTypesAnalysisPolicy < Struct.new(:user, :dashboard)
    def show?
      user.present? && (user.admin? || user.chinese_name.in?(%w(王旭冉 王俐雯))
      )
    end
  end
end
