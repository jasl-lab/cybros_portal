class Company::ItKnowledgeMaintainsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_it_knowledge, only: [:edit, :update, :destroy]
  before_action :set_breadcrumbs, only: %i[index new edit], if: -> { request.format.html? }
  after_action :verify_authorized

  def index
    authorize Company::ItKnowledge
    @it_knowledges = Company::ItKnowledge.all
  end

  def new
    @it_knowledge = Company::ItKnowledge.new
    authorize @it_knowledge
  end

  def edit
  end

  def create
    @it_knowledge = Company::ItKnowledge.new(it_knowledge_params)
    authorize @it_knowledge

    respond_to do |format|
      if @it_knowledge.save
        format.html { redirect_to @it_knowledge, notice: 'It knowledge maintain was successfully created.' }
        format.json { render :show, status: :created, location: @it_knowledge_maintain }
      else
        format.html { render :new }
        format.json { render json: @it_knowledge.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @it_knowledge.update(it_knowledge_params)
      redirect_to company_it_knowledge_maintains_path, notice: 'It knowledge maintain was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @it_knowledge.destroy
    respond_to do |format|
      format.html { redirect_to it_knowledge_maintains_url, notice: 'It knowledge maintain was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  protected

  def set_page_layout_data
    @_sidebar_name = "company"
  end

  def set_breadcrumbs
    @_breadcrumbs = [
    { text: t("layouts.sidebar.application.header"),
      link: root_path },
    { text: t("layouts.sidebar.company.header"),
      link: person_root_path },
    { text: t("layouts.sidebar.company.it_knowledge_maintains"),
      link: company_it_knowledge_maintains_path }]
  end

  private

  def set_it_knowledge
    @it_knowledge = Company::ItKnowledge.find(params[:id])
    authorize @it_knowledge
  end

  def it_knowledge_params
    params.require(:company_it_knowledge).permit(:application, :category, :question, :answer)
  end
end
