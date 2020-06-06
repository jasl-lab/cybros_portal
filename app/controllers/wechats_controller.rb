class WechatsController < ApplicationController
  # For details on the DSL available within this file, see https://github.com/Eric-Guo/wechat#wechat_responder---rails-responder-controller-dsl
  wechat_responder
  GREATING_1 = %w(Hi~~~我是人见人爱的小华 来啦来啦，我是小华 我是小华，找我啥事).freeze
  GREATING_2 = %w(我可以回答很多问题哦，比如： 我猜你想问这些？).freeze

  on :text do |request, content|
    Current.user = User.find_by email: "#{request[:FromUserName]}@thape.com.cn"

    ks = Company::Knowledge.answer(content)
    if ks.present?
      k = ks.first
      Rails.logger.debug "User question: #{content} answered as question: #{k.question}"
      if k.answer_contain_text_only? && ks.count == 1
        request.reply.text k.answer.to_plain_text
      else
        news = ks.each_with_object([]) do |q, memo|
          memo << { title: q.question, content: "类别：#{q.category_1} #{q.category_2} #{q.category_3}", k: q }
        end
        request.reply.news(news) do |article, n, index|
          pic_url = ActionController::Base.helpers.asset_url(Company::KnowledgeImages.random_one, type: :image)
          article.item title: n[:title], description: n[:content],
            pic_url: pic_url,
            url: company_home_knowledge_url(n[:k])
        end
      end
    else
      if Current.user.present?
        Current.user.pending_questions.create(question: content)
      else
        Rails.logger.debug "User question not answer: #{content}"
      end
      request.reply.text Company::Knowledge.no_answer_content
    end
  end

  on :voice do |request|
    Current.user = User.find_by email: "#{request[:FromUserName]}@thape.com.cn"
    voice_id = request[:MediaId]
    Rails.logger.debug "voice_id: #{voice_id}"
    VoiceAnswerWorker.perform_async(voice_id, Current.user&.id)
    request.reply.text "🤔"
  end

  on :event, with: 'enter_agent' do |request|
    return request.reply.success if request.session.greating_time&.to_date == Time.current.to_date

    g1 = GREATING_1.sample
    g2 = GREATING_2.sample
    human_resources_question = Company::Knowledge.where(category_1: '人力资源').sample
    finance_question = Company::Knowledge.where(category_1: '财务').sample
    process_information_question = Company::Knowledge.where(category_1: '流程与信息化').sample

    request.session.greating_time = Time.current
    request.reply.text "#{g1}\r\n#{g2}\r\n<a href='#{company_home_knowledge_url(human_resources_question)}'>#{human_resources_question.question}</a>\r\n<a href='#{company_home_knowledge_url(finance_question)}'>#{finance_question.question}</a>\r\n<a href='#{company_home_knowledge_url(process_information_question)}'>#{process_information_question.question}</a>"
  end
end
