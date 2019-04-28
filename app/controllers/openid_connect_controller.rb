class OpenidConnectController < ApplicationController
  def callback
    @omniaut_auth = request.env['omniauth.auth']
    # Rails.logger.debug "omniaut_auth: " + JSON.pretty_generate(@omniaut_auth)
    user = User.find_or_create_by!(email: @omniaut_auth.dig(:info, :email)) do |user|
      user.confirmed_at = Time.current
      random_password = SecureRandom.hex(4) # like "301bccce"
      user.password = random_password
      user.password_confirmation = random_password
    end
    main_position_title = @omniaut_auth.dig(:extra, :raw_info, :main_position, :name)
    departments = @omniaut_auth.dig(:extra, :raw_info, :departments)
    departments.each do |d|
      d = Department.find_or_create_by(id: d[:id], name: d[:name])
      DepartmentUser.find_or_create_by!(user_id: user.id, department_id: d.id)
    end
    user.update(position_title: main_position_title)

    sign_in user
    redirect_to root_path
  end
end
