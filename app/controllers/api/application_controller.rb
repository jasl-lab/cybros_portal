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
      white_jwts_attrs = params[:white_jwts_attrs]
      email = params[:email]
      jti = white_jwts_attrs[:jti]
      aud = white_jwts_attrs[:aud]
      exp = white_jwts_attrs[:exp]

      user = User.find_or_initialize_by(email: email)
      user.position_title = params[:position_title]
      user.clerk_code = params[:clerk_code]
      user.chinese_name = params[:chinese_name]
      user.job_level = params[:job_level]
      user.locked_at = params[:locked_at]
      user.desk_phone = params[:desk_phone]
      user.confirmed_at = Time.current
      if user.new_record?
        random_password = SecureRandom.hex(4) # like "301bccce"
        user.password = random_password
        user.password_confirmation = random_password
      end

      user.save

      params[:departments].each do |d|
        id = d[:id]
        department_name = d[:name]
        dept_code = d[:dept_code]
        company_name = d[:company_name]
        company_code = d[:company_code]

        dep = Department.find_or_create_by(id: id) do |department|
          department.name = department_name
        end
        dep.update(company_name: company_name, company_code: company_code, name: department_name, dept_code: dept_code)
        DepartmentUser.find_or_create_by!(user_id: user.id, department_id: dep.id)
      end

      user.allowlisted_jwts.create(jti: jti, aud: aud, exp: exp)
      head :ok
    end
  end
end
