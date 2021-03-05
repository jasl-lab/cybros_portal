# frozen_string_literal: true

module API
  class WechatMiniUsersController < WechatMiniBaseController
    before_action :authenticate_wechat_user!

    def show
      @wechat_user = current_wechat_user
      @identities = []
      if @wechat_user.user_id.present? && user = User.find(@wechat_user.user_id)
        @wechat_user.nick_name = user.chinese_name
        @identities.push 'insider'
        @identities.push 'commercial' if has_auth
      end
    end

    def update
      encrypted_data = params[:encrypted_data]
      iv = params[:iv]
      appid = Wechat.api('mini').access_token.appid
      openid = current_wechat_user.open_id
      session_key = current_wechat_user.session_key
      userinfo = Wechat.decrypt(encrypted_data, session_key, iv)
      unless userinfo && userinfo['watermark'] && userinfo['watermark']['appid'] == appid && userinfo['openId'] == openid
        raise Pundit::NotAuthorizedError.new '用户信息有误'
      end
      current_wechat_user.nick_name = userinfo['nickName']
      current_wechat_user.avatar_url = userinfo['avatarUrl']
      current_wechat_user.gender = userinfo['gender']
      current_wechat_user.province = userinfo['province']
      current_wechat_user.city = userinfo['city']
      current_wechat_user.country = userinfo['country']
      current_wechat_user.save
      @wechat_user = current_wechat_user
    end

    def mobile
      encrypted_data = params[:encrypted_data]
      iv = params[:iv]
      appid = Wechat.api('mini').access_token.appid
      session_key = current_wechat_user.session_key
      data = Wechat.decrypt(encrypted_data, session_key, iv)
      unless data && data['watermark'] && data['watermark']['appid'] == appid
        raise Pundit::NotAuthorizedError.new '用户信息有误'
      end
      current_wechat_user.mobile = data['phoneNumber']
      current_wechat_user.save
      @wechat_user = current_wechat_user
    end
  end
end
