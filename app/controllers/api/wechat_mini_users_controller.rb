# frozen_string_literal: true

module API
  class WechatMiniUsersController < WechatMiniBaseController
    before_action :authenticate_wechat_user!

    def show
      @wechat_user = current_wechat_user
      @identities = []
      if @wechat_user.user_id.present? && user = User.find(@wechat_user.user_id)
        sign_in user
        @wechat_user.nick_name = user.chinese_name
        @identities.push 'insider'
        @identities.push 'commercial' if policy(Bi::NewMapInfo).show?
      end
    end

    def update
      encrypted_data = params[:encrypted_data]
      iv = params[:iv]
      appid = Wechat.api('mini').access_token.appid
      openid = current_wechat_user.open_id
      session_key = current_wechat_user.session_key
      userinfo = Wechat.decrypt(encrypted_data, session_key, iv)
      if userinfo.present? && userinfo['watermark'] && userinfo['watermark']['appid'] == appid && userinfo['openId'] == openid
        current_wechat_user.nick_name = userinfo['nickName']
        current_wechat_user.avatar_url = userinfo['avatarUrl']
        current_wechat_user.gender = userinfo['gender']
        current_wechat_user.province = userinfo['province']
        current_wechat_user.city = userinfo['city']
        current_wechat_user.country = userinfo['country']
        current_wechat_user.save
        @wechat_user = current_wechat_user
      else
        render json: { errMsg: '用户信息有误', errCOde: 400 }, status: :bad_request
      end
    end

    def mobile
      encrypted_data = params[:encrypted_data]
      iv = params[:iv]
      appid = Wechat.api('mini').access_token.appid
      session_key = current_wechat_user.session_key
      data = Wechat.decrypt(encrypted_data, session_key, iv)
      if data && data['watermark'] && data['watermark']['appid'] == appid
        current_wechat_user.mobile = data['phoneNumber']
        current_wechat_user.save
        @wechat_user = current_wechat_user
      else
        render json: { errMsg: '用户信息有误', errCOde: 400 }, status: :bad_request
      end
    end
  end
end
