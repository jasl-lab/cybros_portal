# frozen_string_literal: true

class Admin::BaselinePositionAccessesController < Admin::ApplicationController
  before_action :set_baseline_position_access, except: %i[index]

  def index
    prepare_meta_tags title: t('.title')
    @baseline_position_accesses = BaselinePositionAccess.all
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
