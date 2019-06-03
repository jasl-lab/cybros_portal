class Company::KnowledgesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_knowledge, only: [:modal]
  after_action :verify_authorized

  def modal
  end

  private

  def set_knowledge
    @knowledge = Company::Knowledge.find(params[:id])
    authorize @knowledge
  end
end
