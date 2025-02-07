# frozen_string_literal: true

# Used by wechat gems, do not rename WechatSession to other name,
class WechatSession < ActiveRecord::Base
  validates :openid, presence: true, uniqueness: true

  # called by wechat gems when user request session
  def self.find_or_initialize_session(request_message)
    find_or_initialize_by(openid: request_message[:from_user_name])
  end

  # called by wechat gems after response Techent server at controller#create
  def save_session(_response_message)
    touch unless new_record? # Always refresh updated_at even no change
    save!
  end
end
