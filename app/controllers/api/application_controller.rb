# frozen_string_literal: true

module API
  class ApplicationController < ActionController::API
    before_action :authenticate_user!

    def user_info
      u = current_user
      departments = u.departments.collect do |department|
        { id: department.id, name: department.name, company_name: department.company_name }
      end
      render json: {
        email: u.email,
        position_title: u.position_title,
        clerk_code: u.clerk_code,
        chinese_name: u.chinese_name,
        desk_phone: u.desk_phone,
        departments: departments
      }
    end
  end
end
