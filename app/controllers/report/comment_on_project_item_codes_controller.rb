# frozen_string_literal: true

class Report::CommentOnProjectItemCodesController < ApplicationController
  def create
    cop_params = comment_on_project_item_code_params
    @cop = Bi::CommentOnProjectItemCode.find_or_initialize_by(project_item_code: cop_params[:project_item_code], record_month: cop_params[:record_month])
    @cop.update(cop_params)
  end

  private

    def comment_on_project_item_code_params
      params[:bi_comment_on_project_item_code].permit(:project_item_code, :record_month, :comment)
    end
end
