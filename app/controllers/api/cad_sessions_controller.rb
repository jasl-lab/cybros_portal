# frozen_string_literal: true

module API
  class CadSessionsController < ApplicationController
    before_action :authenticate_user!

    def create
      cad_session = current_user.cad_sessions.create(cad_sessions_params)
      if cad_session.persisted?
        head :created
      else
        render json: { error: cad_session.errors.full_messages }, status: :bad_request
      end
    end

    private

      def cad_sessions_params
        params.fetch(:cad_session, {}).permit(:session, :operation, :ip_address, :mac_address)
      end
  end
end
