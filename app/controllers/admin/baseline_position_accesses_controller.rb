# frozen_string_literal: true

class Admin::BaselinePositionAccessesController < Admin::ApplicationController
  before_action :set_baseline_position_access, except: %i[index]

  def index
    prepare_meta_tags title: t('.title')
    @b_postcode = params[:b_postcode]
    @b_postname = params[:b_postname]
    @contract_map_access = params[:contract_map_access]
    @baseline_position_accesses = BaselinePositionAccess.all
    @baseline_position_accesses = @baseline_position_accesses.where(b_postcode: @b_postcode) if @b_postcode.present?
    @baseline_position_accesses = @baseline_position_accesses.where('b_postname LIKE ?', "%#{@b_postname}%") if @b_postname.present?
    @baseline_position_accesses = @baseline_position_accesses.where(contract_map_access: @contract_map_access) if @contract_map_access.present?
  end

  def edit
  end

  def show
    render :update
  end

  def update
    @baseline_position_access.update(baseline_position_access_params)
  end

  private

    def set_baseline_position_access
      @baseline_position_access = BaselinePositionAccess.find(params[:id])
    end

    def baseline_position_access_params
      params.fetch(:baseline_position_access, {}).permit(:contract_map_access)
    end
end
