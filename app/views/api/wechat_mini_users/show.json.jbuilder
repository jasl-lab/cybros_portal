json.userinfo @wechat_user, partial: 'userinfo', as: :userinfo
json.hasBindMobile @wechat_user.mobile.present?
json.insider @insider
