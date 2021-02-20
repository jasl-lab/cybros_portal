json.key_format! camelize: :lower
json.userinfo @wechat_user, partial: 'userinfo', as: :userinfo
json.bind_mobile @bind_mobile
json.insider @insider