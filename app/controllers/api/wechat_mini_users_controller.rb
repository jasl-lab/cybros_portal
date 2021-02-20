# frozen_string_literal: true

module API
  class WechatMiniUsersController < ApplicationController
    before_action :authenticate_wechat_user!

    def show
      render json: { userinfo: current_wechat_user }
    end

    def update
      encrypted_data = params[:encrypted_data]
      iv = params[:iv]
      appid = Wechat.api('mini').access_token.appid
      openid = current_wechat_user.openid
      session_key = current_wechat_user.session_key
      userinfo = Wechat.decrypt(encrypted_data, session_key, iv)
      current_wechat_user.update userinfo
      render json: { userinfo: current_wechat_user }
    end
  end
end
