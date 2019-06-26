class Company::KnowledgesController < ApplicationController
  wechat_api
  before_action :authenticate_user!, except: :show
  before_action :set_knowledge, only: [:modal, :show]
  after_action :verify_authorized

  def show
    wechat_oauth2 do |user_name|
      Current.user = User.find_by email: "#{user_name}@thape.com.cn"
      sign_in Current.user
    end
  end

  def modal
  end

  private

  def set_knowledge
    @knowledge = Company::Knowledge.find(params[:id])
    authorize @knowledge
  end
end
