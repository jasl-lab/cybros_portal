# frozen_string_literal: true

json.users do
  json.array! @users do |user|
    json.id user.id
    json.chinese_name user.chinese_name
  end
end
