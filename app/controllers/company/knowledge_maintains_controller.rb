class Company::KnowledgeMaintainsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_knowledge, only: [:edit, :update, :destroy]
  before_action :set_breadcrumbs, only: %i[index new edit], if: -> { request.format.html? }
  after_action :verify_authorized

  def index
    authorize Company::Knowledge
    @knowledges = Company::Knowledge.all.page(params[:page]).per(params[:per_page])
  end

  def new
    @knowledge = Company::Knowledge.new
    authorize @knowledge
  end

  def edit
  end

  def create
    @knowledge = Company::Knowledge.new(knowledge_params)
    authorize @knowledge

    if @knowledge.save
      redirect_to company_knowledge_maintains_path, notice: t('.success')
    else
      render :new
    end
  end

  def update
    if @knowledge.update(knowledge_params)
      redirect_to company_knowledge_maintains_path, notice: t('.success')
    else
      render :edit
    end
  end

  def destroy
    @knowledge.destroy
    redirect_to company_knowledge_maintains_path, notice: t('.success')
  end

  def export
    authorize Company::Knowledge

    respond_to do |format|
      format.csv do
        render_csv_header 'Knowledge Report'
        csv_res = CSV.generate do |csv|
          csv << ['ID', '类别1', '类别2', '类别3', '问题']
          policy_scope(Company::Knowledge).order(id: :asc).find_each do |s|
            values = []
            values << s.id
            values << s.category_1
            values << s.category_2
            values << s.category_3
            values << s.question
            csv << values
          end
        end
        send_data "\xEF\xBB\xBF" << csv_res
      end
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
    { text: t("layouts.sidebar.company.knowledge_maintains"),
      link: company_knowledge_maintains_path }]
  end

  private

  def set_knowledge
    @knowledge = Company::Knowledge.find(params[:id])
    authorize @knowledge
  end

  def knowledge_params
    params.require(:company_knowledge).permit(:category_1, :category_2, :category_3, :question, :answer)
  end
end
