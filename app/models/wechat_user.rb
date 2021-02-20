# frozen_string_literal: true

class WechatUser < ActiveRecord::Base
  devise :database_authenticatable, :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  def self.find_for_jwt_authentication(sub)
    find_by(id: sub)
  end
end
