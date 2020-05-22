# frozen_string_literal: true

module AttachmentValidate
  extend ActiveSupport::Concern

  included do
    validate :attachment_validation

    def attachment_validation
      if attachments.attached?
        attachments.each do |attachment|
          if attachment.blob.byte_size > 25.megabyte
            errors[:attachment] << '上传附件不能超过25M'
          end
          unless attachment.blob.content_type.starts_with?('image/') ||
            attachment.blob.content_type.in?(%w[application/msword application/pdf application/vnd.openxmlformats-officedocument.wordprocessingml.document])
            errors[:attachment] << '上传证书不是图片，word或者PDF格式'
          end
        end
      end
    end
  end
end
