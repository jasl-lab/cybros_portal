# frozen_string_literal: true

module API
  class NameCardsController < ActionController::API
    def create
      name_card_apply = NameCardApply.find_by id: params[:name_card_id]
      return render json: { is_success: 404, error_message: '找不到记录' }, status: :not_found unless name_card_apply.present?

      name_card_apply.bpm_message = params[:message]
      if params[:approval_result].to_i == 1
        name_card_apply.status = '同意'
      else
        name_card_apply.status = '否决'
      end
      if name_card_apply.save(validate: false)
        render json: { is_success: true }, status: :ok
      else
        render json: { is_success: 400, error_message: name_card_apply.errors.full_messages }, status: :bad_request
      end
    end
  end
end
