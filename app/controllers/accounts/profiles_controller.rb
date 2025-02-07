# frozen_string_literal: true

module Accounts
  class ProfilesController < Accounts::ApplicationController
    before_action :set_user

    # GET /account/profile
    def show
    end

    # PUT /account/profile
    def update
      if @user.update_without_password(user_params)
        redirect_to after_update_url, notice: t('accounts.profiles.show.updated')
      else
        render :show
      end
    end

    private

      def set_user
        @user = current_user
      end

      def user_params
        params.require(:user).permit(:open_in_new_tab, :per_page)
      end

      def after_update_url
        account_profile_url
      end
  end
end
