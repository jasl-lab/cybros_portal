# frozen_string_literal: true

module AttachmentValidate
  extend ActiveSupport::Concern

  included do
    validate :attachment_validation

    def attachment_validation
      if attachment.attached?
        if attachment.blob.byte_size > 4096.kilobytes
          errors[:attachment] << '上传附件不能超过4M'
        end
        unless attachment.blob.content_type.starts_with?('image/') ||
          attachment.blob.content_type.in?(%w[application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document])
          errors[:attachment] << '上传证书不是图片格式或者word格式'
        end
      end
    end
  end
end
