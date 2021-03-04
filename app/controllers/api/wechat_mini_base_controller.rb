# frozen_string_literal: true

module API
  class WechatMiniBaseController < ActionController::API
    include Pundit
    include ActionController::ImplicitRender
    include ActionView::Layouts

    def make_sure_auth
      raise Pundit::NotAuthorizedError.new '未绑定手机号' unless current_wechat_user.mobile
      user = User.find_by mobile: current_wechat_user.mobile
      raise Pundit::NotAuthorizedError.new '仅限天华人员访问' unless user
      sign_in user
      raise Pundit::NotAuthorizedError.new '无权限访问' unless policy(Bi::NewMapInfo).show?
    end

    def has_auth
      return false unless current_wechat_user.mobile.present?
      user = User.find_by mobile: current_wechat_user.mobile
      return false unless user.present?
      sign_in user
      policy(Bi::NewMapInfo).show?
    end
  end
end
