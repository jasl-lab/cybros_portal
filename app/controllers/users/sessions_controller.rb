# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    before_action -> { prepare_meta_tags title: t('users.sessions.new.title') },
      if: -> { request.format.html? }, only: [:new, :create]
    protect_from_forgery with: :null_session, if: -> { request.format.json? }
    skip_before_action :verify_signed_out_user, if: -> { request.format.json? }
    respond_to :json, if: -> { request.format.json? }
    after_action :cors_set_access_control_headers
    layout 'sign_in'

    # before_action :configure_sign_in_params, only: [:create]

    def new
      super
    end

    def create
      super
    end

    # DELETE /resource/sign_out
    # def destroy
    #   super
    # end

    protected

      # If you have extra params to permit, append them to the sanitizer.
      # def configure_sign_in_params
      #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
      # end

      def cors_set_access_control_headers
        headers['Access-Control-Allow-Origin'] = '*'
        headers['Access-Control-Allow-Methods'] = 'GET'
        headers['Access-Control-Request-Method'] = '*'
        headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
        headers['X-Frame-Options'] = 'ALLOW-FROM http://172.16.1.159'
        headers['X-XSS-Protection'] = '0'
      end
  end
end
