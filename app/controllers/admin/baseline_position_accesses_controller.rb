# frozen_string_literal: true

class Admin::BaselinePositionAccessesController < Admin::ApplicationController
  def index
    prepare_meta_tags title: t('.title')
    @baseline_position_accesses = BaselinePositionAccess.all
  end
end
