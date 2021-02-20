# frozen_string_literal: true

module API
  class WechatMiniBaseController < ActionController::API
    include Pundit
    include ActionController::ImplicitRender
    include ActionView::Layouts

    def make_sure_auth
      unless current_wechat_user.mobile
        # 抛出错误 未绑定手机号
      end
      user = User.find_by mobile: current_wechat_user.mobile
      unless user
        # 抛出错误 仅限内部人员访问
      end
      sign_in user
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
