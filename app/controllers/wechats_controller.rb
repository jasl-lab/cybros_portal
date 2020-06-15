class WechatsController < ApplicationController
  # For details on the DSL available within this file, see https://github.com/Eric-Guo/wechat#wechat_responder---rails-responder-controller-dsl
  wechat_responder
  GREATING_1 = %w(Hi~~~我是人见人爱的小华 来啦来啦，我是小华 我是小华，找我啥事).freeze
  GREATING_2 = %w(我可以回答很多问题哦，比如： 我猜你想问这些？).freeze

  on :text do |request, content|
    Current.user = User.find_by email: "#{email_name(request[:FromUserName])}@thape.com.cn"

    ks = Company::Knowledge.answer(content)
    if ks.present?
      k = ks.first
      Rails.logger.debug "User name: #{email_name(request[:FromUserName])}, User company: #{Current.user.user_company_short_name}, " +
      "department: #{Current.user.user_department_name}, User question: #{content} " +
      "Question category: #{k.category_1}, answered as question: #{k.question}"
      if k.can_show_text_directly? && ks.count == 1
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
    Current.user = User.find_by email: "#{email_name(request[:FromUserName])}@thape.com.cn"
    voice_id = request[:MediaId]
    Rails.logger.debug "voice_id: #{voice_id}"
    VoiceAnswerWorker.perform_async(voice_id, Current.user&.id)
    request.reply.text "🤔"
  end

  on :click, with: 'LIKE_US' do |request, key|
    Current.user = User.find_by email: "#{email_name(request[:FromUserName])}@thape.com.cn"

    kl = Company::KnowledgeLike.find_or_create_by(user_id: Current.user.id) do |knowledge_like|
      knowledge_like.like_count = 0
    end
    kl.update(like_count: kl.like_count + 1)

    request.reply.text "谢谢你夸奖我。🥰"
  end

  on :event, with: 'enter_agent' do |request|
    return request.reply.success if request.session.present? && request.session.greating_time.present? && request.session.greating_time >= 1.week.ago

    g1 = GREATING_1.sample
    g2 = GREATING_2.sample
    human_resources_question = Company::Knowledge.where(category_1: '人力资源').sample
    finance_question = Company::Knowledge.where(category_1: '财务').sample
    process_information_question = Company::Knowledge.where(category_1: '流程与信息化').sample

    request.session.greating_time = Time.current
    request.reply.text "#{g1}\r\n#{g2}\r\n<a href='#{company_home_knowledge_url(human_resources_question)}'>#{human_resources_question.question}</a>\r\n<a href='#{company_home_knowledge_url(finance_question)}'>#{finance_question.question}</a>\r\n<a href='#{company_home_knowledge_url(process_information_question)}'>#{process_information_question.question}</a>"
  end

  def email_name(user_name)
    if user_name == 'x'
      'xuxiaohong'
    else
      user_name
    end
  end
end
