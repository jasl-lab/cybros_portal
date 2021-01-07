# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :user

  def jieba_keyword
    @jieba_keyword ||= JiebaRb::Keyword.new user_dict: Rails.root.join('config', 'user.dict.utf8').to_s
  end

  def jieba_tagging
    @jieba_tagging ||= JiebaRb::Tagging.new user_dict: Rails.root.join('config', 'user.dict.utf8').to_s
  end
end
