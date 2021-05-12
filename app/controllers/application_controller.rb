# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  before_action :prepare_meta_tags, if: -> { request.format.html? }
  before_action :set_current_user

  include StoreLocation

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

    def my_per_page
      params[:per_page].presence || current_user&.per_page || 12
    end
    helper_method :my_per_page

    def render_csv_header(filename)
      file_name = "#{filename.parameterize}.csv"

      if /msie/i.match?(request.env['HTTP_USER_AGENT'])
        response.set_header('Pragma', 'public')
        response.set_header('Content-type', 'text/plain')
        response.set_header('Cache-Control', 'no-cache, must-revalidate, post-check=0, pre-check=0')
        response.set_header('Content-Disposition', "attachment; filename=\"#{file_name}\"")
        response.set_header('Expires', '0')
      else
        response.set_header('Content-Type', 'text/csv')
        response.set_header('Content-Disposition', "attachment; filename=\"#{file_name}\"")
      end
    end

    def prepare_meta_tags(options = {})
      site_name   = Settings.seo_meta.name
      title       = nil
      description = Settings.seo_meta.description
      current_url = request.url

      # Let's prepare a nice set of defaults
      defaults = {
        site:        site_name,
        title:       title,
        description: description,
        keywords:    Settings.seo_meta.keywords,
        og: {
          url: current_url,
          site_name: site_name,
          title: title,
          description: description,
          type: 'website'
        }
      }

      options.reverse_merge!(defaults)

      set_meta_tags options
    end

    def forbidden!(redirect_url: nil)
      if redirect_url.present?
        store_location redirect_url
      else
        store_location request.referrer
      end

      redirect_to forbidden_url
    end

    %w(forbidden unauthorized).each do |s|
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{s}!(redirect_url: nil)
        if redirect_url.present?
          store_location redirect_url
        else
          store_location request.referrer
        end

        redirect_to #{s}_url
      end
      RUBY_EVAL
    end

    def make_sure_wechat_user_login
      wechat_oauth2 do |user_name|
        Current.user = User.find_by email: "#{user_name}@thape.com.cn"
        if Current.user.present?
          sign_in Current.user
        else
          return redirect_to new_user_session_path
        end
      end unless current_user.present?
    end

    def record_user_view_history
      current_user.report_view_histories.create(controller_name: controller_path, action_name: action_name)
    end

  private

    def set_current_user
      Current.user = current_user
    end

    def user_not_authorized
      flash[:alert] ||= t('not_authorized')
      redirect_to(request.referrer || root_path)
    end
end
