class OpenidConnectController < ApplicationController
  def callback
    @omniaut_auth = request.env['omniauth.auth']
    user = User.find_or_create_by!(email: @omniaut_auth.dig(:info, :email)) do |user|
      user.confirmed_at = Time.current
      random_password = SecureRandom.hex(4) # like "301bccce"
      user.password = random_password
      user.password_confirmation = random_password
    end
    sign_in user
    redirect_to root_path
  end
end
