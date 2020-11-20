# frozen_string_literal: true

class DownloadPersonalNameCardMailer < ApplicationMailer
  def download_link_email
    @name_card_apply = NameCardApply.find(params[:name_card_apply_id])
    @user = @name_card_apply.user
    mail(to: @user.email, subject: '您的电子名片已经可以下载')
  end
end
