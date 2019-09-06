# frozen_string_literal: true

module API
  class ApplicationController < ActionController::API
    before_action :authenticate_user!, only: [:user_info]

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

    def sync_white_jwts
      email = params[:email]
      jti = params[:jti]
      aud = params[:aud]
      exp = params[:exp]
      user = User.find_by(email: email)
      if user.present?
        user.whitelisted_jwts.create(jti: jti, aud: aud, exp: exp)
      end
      head :ok
    end
  end
end
