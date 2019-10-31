# frozen_string_literal: true

module API
  class CadSessionsController < ApplicationController
    before_action :authenticate_user!

    def create
      sessions_params = cad_sessions_params
      previous_begin_session = find_previous_begin_session(sessions_params)

      if previous_begin_session.present?
        previous_begin_session.update(operation: sessions_params[:operation], end_operation: sessions_params[:operation])
        head :created
      else
        cad_session = current_user.cad_sessions.create(sessions_params)
        if cad_session.persisted?
          cad_session.update(begin_operation: 'Begin') if sessions_params[:operation] == 'Begin'
          head :created
        else
          render json: { error: cad_session.errors.full_messages }, status: :bad_request
        end
      end
    end

    def find_previous_begin_session(sessions_params)
      current_user.cad_sessions.find_by(session: sessions_params[:session], begin_operation: 'Begin')
    end

    private

      def cad_sessions_params
        params.fetch(:cad_session, {}).permit(:session, :operation, :ip_address, :mac_address)
      end
  end
end
