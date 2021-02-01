# frozen_string_literal: true

json.users do
  json.array! @users do |user|
    json.clerk_code user.clerk_code
    json.chinese_name user.chinese_name
  end
end
