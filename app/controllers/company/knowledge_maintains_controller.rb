class Company::KnowledgeMaintainsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.format.html? }
  before_action :set_knowledge, only: [:edit, :update, :destroy]
  before_action :set_breadcrumbs, only: %i[index new edit], if: -> { request.format.html? }
  after_action :verify_authorized

  def index
    authorize Company::Knowledge
    @category_1_list = Company::Knowledge.distinct.pluck(:category_1)
    @category_2_list = Company::Knowledge.distinct.pluck(:category_2)
    @category_3_list = Company::Knowledge.distinct.pluck(:category_3)
    knowledges = Company::Knowledge.all
    knowledges = knowledges.where(shanghai_only: params[:shanghai_only]) if params[:shanghai_only].present?
    knowledges = knowledges.where(category_1: params[:category_1]) if params[:category_1].present?
    knowledges = knowledges.where(category_2: params[:category_2]) if params[:category_2].present?
    knowledges = knowledges.where(category_3: params[:category_3]) if params[:category_3].present?
    knowledges = knowledges.where('question LIKE ?', "%#{params[:question]}%") if params[:question].present?
    @knowledges = knowledges.page(params[:page]).per(params[:per_page])
  end

  def new
    @knowledge = Company::Knowledge.new
    @knowledge.question = params[:q]
    @knowledge.q_user_id = params[:q_user_id]
    @category_1_list = Company::Knowledge.distinct.pluck(:category_1)
    authorize @knowledge
  end

  def edit
    @category_1_list = Company::Knowledge.distinct.pluck(:category_1)
  end

  def create
    @knowledge = Company::Knowledge.new(knowledge_params)
    authorize @knowledge

    if @knowledge.save
      if @knowledge.q_user_id.present?
        notify_user = User.find @knowledge.q_user_id
        if notify_user.present?
          openid = notify_user.email.split('@')[0]
          Wechat.api.custom_message_send Wechat::Message.to(openid).text("您的问题：#{@knowledge.question} 已经有了答案：\r\n#{@knowledge.answer.to_plain_text}")
        end
      end
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
          csv << ['ID', '类别1', '类别2', '类别3', '问题', '答案']
          policy_scope(Company::Knowledge).order(id: :asc).find_each do |s|
            values = []
            values << s.id
            values << s.category_1
            values << s.category_2
            values << s.category_3
            values << s.question
            values << s.answer.to_plain_text
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
      link: company_root_path },
    { text: t("layouts.sidebar.company.knowledge_maintains"),
      link: company_knowledge_maintains_path }]
  end

  private

  def set_knowledge
    @knowledge = Company::Knowledge.find(params[:id])
    authorize @knowledge
  end

  def knowledge_params
    params.require(:company_knowledge).permit(:category_1, :category_2, :category_3, :question, :answer, :shanghai_only, :q_user_id)
  end
end
