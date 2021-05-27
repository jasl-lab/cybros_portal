# frozen_string_literal: true

module API
  class ReceivedSmsMessagesController < ActionController::API
    def create
      return render json: { is_success: 403, error_message: '此 API 仅允许内网调用。' }, status: :forbidden unless request.remote_ip.start_with?('172.') || request.remote_ip.start_with?('10.') || request.remote_ip == '127.0.0.1'

      receive_id = params[:receiveId]
      content = params[:content]

      if receive_id.present? && content.present?
        Company::ReceivedSmsMessage.create(receive_id: receive_id, content: content)
        render json: { is_success: true }, status: :ok
      else
        render json: { is_success: false }, status: :bad_request
      end
    end

    def show
      return render json: { is_success: 403, error_message: '此 API 仅允许内网调用。' }, status: :forbidden unless request.remote_ip.start_with?('172.') || request.remote_ip.start_with?('10.') || request.remote_ip == '127.0.0.1'
      receive_ids = params[:receiveIds]&.split(',')
      battery = params[:battery]&.to_i
      is_charging = params[:is_charging]

      sms_phone_mapping = Company::SmsPhoneMapping.where(receive_id: receive_ids)
      if sms_phone_mapping.present?
        sms_phone_mapping.update(battery: battery, charging: is_charging)
        render json: { is_success: true }, status: :ok
      else
        render json: { is_success: false }, status: :bad_request
      end
    end
  end
end
