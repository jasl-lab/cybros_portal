# frozen_string_literal: true

module API
  class CadOperationsController < ApplicationController
    before_action :authenticate_user!

    def create
      cad_operation = current_user.cad_operations.create(
        session_id: params[:session_id],
        cmd_name: params[:cmd_name],
        cmd_seconds: params[:cmd_seconds],
        cmd_data: params[:cmd_data].to_json
      )
      if cad_operation.persisted?
        head :created
      else
        render json: { error: cad_operation.errors.full_messages }, status: :bad_request
      end
    end
  end
end
