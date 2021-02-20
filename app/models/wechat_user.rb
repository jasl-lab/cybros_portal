# frozen_string_literal: true

class WechatUser < ActiveRecord::Base
  devise :database_authenticatable, :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null
end
