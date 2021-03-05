# frozen_string_literal: true

module API
  class WechatMiniBaseController < ActionController::API
    include Pundit
    include ActionController::ImplicitRender
    include ActionView::Layouts

    rescue_from Pundit::NotAuthorizedError, with: :user_forbidden

    def make_sure_auth
      raise Pundit::NotAuthorizedError.new '仅限天华人员访问' unless User.exists?(current_wechat_user&.user_id)
      sign_in user
    end

    def has_auth
      return false unless current_wechat_user.user_id.present? && user = User.find(current_wechat_user.user_id)
      true
    end

    def user_forbidden
      head :forbidden
    end
  end
end
