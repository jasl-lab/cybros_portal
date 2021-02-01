# frozen_string_literal: true

class UI::NcworknoSelectsController < UI::BaseController
  before_action :authenticate_user!

  def show
    @users = User.where('chinese_name LIKE ?', "%#{params[:q]}%").limit(7)
  end
end
