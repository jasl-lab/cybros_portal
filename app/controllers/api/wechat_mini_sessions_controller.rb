# frozen_string_literal: true

module API
  class WechatMiniSessionsController < WechatMiniBaseController
    def create
      code = params[:code]
      wechat = Wechat.api('mini')
      appid = wechat.access_token.appid
      res = wechat.jscode2session(code)
      openid = res["openid"]
      session_key = res["session_key"]
      wechat_user = WechatUser.find_or_initialize_by open_id: openid, app_id: appid
      wechat_user.session_key = session_key
      raise StandardError.new '保存用户信息失败' unless wechat_user.save
      user_encoder = Warden::JWTAuth::UserEncoder.new
      payload = user_encoder.helper.payload_for_user(wechat_user, "wechat_user")
      payload["exp"] = Time.now.to_i + 1.year
      payload["aud"] = 'cybros'
      @jwt = Warden::JWTAuth::TokenEncoder.new.call(payload)
    end
  end
end
