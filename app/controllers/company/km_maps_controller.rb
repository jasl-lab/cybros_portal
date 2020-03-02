# frozen_string_literal: true

class Company::KmMapsController < ApplicationController
  before_action :authenticate_user!

  def show
    @biz_category = params[:biz_category]&.strip
    @prj_category = params[:prj_category]&.strip
    @department = params[:department]&.strip
    @service_stage = params[:service_stage]&.strip
    @scale = params[:scale]&.strip
  end
end
