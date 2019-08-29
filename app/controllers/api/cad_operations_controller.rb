# frozen_string_literal: true

module API
  class CadOperationsController < ApplicationController
    before_action :authenticate_user!

    def create
      cad_operation = current_user.cad_operations.create(cad_operations_params)
      if cad_operation.persisted?
        head :created
      else
        render json: { error: cad_operation.errors.full_messages }, status: :bad_request
      end
    end

    private

      def cad_operations_params
        params.fetch(:cad_operation, {}).permit(:session_id, :cmd_name, :cmd_seconds, :cmd_data)
      end
  end
end
