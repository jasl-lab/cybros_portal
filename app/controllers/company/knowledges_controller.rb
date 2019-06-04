class Company::KnowledgesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_knowledge, only: [:modal, :show]
  after_action :verify_authorized

  def show
  end

  def modal
  end

  private

  def set_knowledge
    @knowledge = Company::Knowledge.find(params[:id])
    authorize @knowledge
  end
end
