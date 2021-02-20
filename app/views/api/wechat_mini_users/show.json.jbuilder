json.key_format! camelize: :lower
json.userinfo do
  json.nick_name @wechat_user.nick_name
  json.avatar_url @wechat_user.avatar_url
  json.gender @wechat_user.gender
  json.province @wechat_user.province
  json.city @wechat_user.city
  json.country @wechat_user.country
end
json.bind_mobile @bind_mobile
json.insider @insider