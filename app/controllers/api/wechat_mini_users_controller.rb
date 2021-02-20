# frozen_string_literal: true

module API
  class WechatMiniUsersController < WechatMiniBaseController
    before_action :authenticate_wechat_user!

    def show
      @wechat_user = current_wechat_user
      @bind_mobile = !!current_wechat_user.mobile
      @insider = has_auth
    end

    def update
      encrypted_data = params[:encrypted_data]
      iv = params[:iv]
      appid = Wechat.api('mini').access_token.appid
      openid = current_wechat_user.open_id
      session_key = current_wechat_user.session_key
      userinfo = Wechat.decrypt(encrypted_data, session_key, iv)
      unless userinfo && userinfo['watermark'] && userinfo['watermark']['appid'] == appid
        raise StandardError.new '用户信息有误'
      end
      @wechat_user = current_wechat_user.update(
        nick_name: userinfo['nickName'],
        avatar_url: userinfo['avatarUrl'],
        gender: userinfo['gender'],
        province: userinfo['province'],
        city: userinfo['city'],
        country: userinfo['country']
      )
    end
  end
end
