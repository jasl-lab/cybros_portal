# frozen_string_literal: true

module API
  class WechatMiniController < ApplicationController
    def login_by_code
      code = params[:code]
      encrypted_data = params[:encrypted_data]
      iv = params[:iv]
      wechat = Wechat.api('mini')
      appid = wechat.access_token.appid
      res = wechat.jscode2session(code)
      openid = res["openid"]
      session_key = res["session_key"]
      puts encrypted_data
      puts session_key
      userinfo = Wechat.decrypt(encrypted_data, session_key, iv)
      render json: userinfo
    end
  end
end
