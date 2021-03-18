# frozen_string_literal: true

class UI::NcworknoSelectsController < UI::BaseController
  before_action :authenticate_user!

  def show
    @users = User.where('chinese_name LIKE ?', "%#{params[:q]}%")
      .or(User.where('clerk_code LIKE ?', "%#{params[:q]}%"))
      .where(locked_at: nil)
      .limit(7)
  end
end
