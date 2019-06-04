class WechatsController < ApplicationController
  # For details on the DSL available within this file, see https://github.com/Eric-Guo/wechat#wechat_responder---rails-responder-controller-dsl
  wechat_responder

  on :text do |request, content|
    k = Company::Knowledge.answer(content)
    if k.present?
      request.reply.text "#{k.question} #{company_home_knowledge_url(k)}"
    else
      request.reply.text "无法回答您的问题：#{content}"
    end
  end
end
