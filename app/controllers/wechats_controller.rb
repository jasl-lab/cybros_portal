class WechatsController < ApplicationController
  # For details on the DSL available within this file, see https://github.com/Eric-Guo/wechat#wechat_responder---rails-responder-controller-dsl
  wechat_responder
  GREATING = %w(Hi~~~我是人见人爱的小华 来啦来啦，我是小华 我是小华，找我啥事).freeze
  NO_ANSWER_FOUND_1 = %w(我还小~还不知道呢 你。。。你问到我了 嗯，这个问题有意思).freeze
  NO_ANSWER_FOUND_2 = %w(我要去学习一下 我得去问问专家 哈哈哈哈哈哈（手动尴尬）).freeze
  NO_ANSWER_FOUND_3 = %w(等我学会了再问我吧，你也可以点击查询更多看看有没有你想要的答案哦).freeze

  on :text do |request, content|
    Current.user = User.find_by email: "#{request[:FromUserName]}@thape.com.cn"

    k = Company::Knowledge.answer(content)
    if k.present?
      Rails.logger.debug "User question: #{content} answered as question: #{k.question}"
      if k.answer_contain_text_only?
        request.reply.text k.answer.to_plain_text
      else
        news = [{ title: k.question, content: "类别：#{k.category_1} #{k.category_2} #{k.category_3}" }]
        request.reply.news(news) do |article, n, index|
          pic_url = ActionController::Base.helpers.asset_url(Company::KnowledgeImages.random_one, type: :image)
          article.item title: n[:title], description: n[:content],
            pic_url: pic_url,
            url: company_home_knowledge_url(k)
        end
      end
    else
      if Current.user.present?
        Current.user.pending_questions.create(question: content)
      else
        Rails.logger.debug "User question not answer: #{content}"
      end
      no_answer = "#{NO_ANSWER_FOUND_1.sample}\r\n#{NO_ANSWER_FOUND_2.sample}\r\n#{NO_ANSWER_FOUND_3.sample}"
      request.reply.text no_answer
    end
  end

  on :event, with: 'enter_agent' do |request|
    request.reply.text GREATING.sample
  end
end
