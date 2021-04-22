# frozen_string_literal: true

class IndexLibrary::BaseController < ApplicationController
  def prepare_encrypt_uid
    login_name = current_user.email.split('@')[0]
    time_stamp = Time.now.to_i
    @uid = AesEncryptDecrypt.encryption("#{login_name}:#{time_stamp}")
  end
end
