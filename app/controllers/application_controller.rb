# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  before_action :prepare_meta_tags, if: -> { request.format.html? }
  before_action :set_current_user

  include StoreLocation

  protected

    def render_csv_header(filename = nil)
      filename ||= params[:action]
      filename += '.csv'

      if request.env['HTTP_USER_AGENT'] =~ /msie/i
        headers['Pragma'] = 'public'
        headers['Content-type'] = 'text/plain'
        headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
        headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
        headers['Expires'] = '0'
      else
        headers['Content-Type'] ||= 'text/csv'
        headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
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
          type: "website"
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

    %w(forbidden unauthorized not_found).each do |s|
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

  private

  def set_current_user
    Current.user = current_user
  end
end
