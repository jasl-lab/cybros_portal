class VoiceAnswerWorker
  include Sidekiq::Worker

  def perform(voice_id, user_id)
    Rails.logger.debug "VoiceAnswerWorker got: #{voice_id} and #{user_id}"
    Current.user = User.find user_id
    in_voice_file = Wechat.api.media(voice_id)
    out_temp = Tempfile.new(['UserVoice', '.mp3'])
    out_temp.close
    `ffmpeg -i #{in_voice_file.path} -acodec mp3 -y -ac 1 -ar 16000 #{out_temp.path}`
    upload_res = Wechat.api(:svca).addvoicetorecofortext(voice_id, File.open(out_temp.path))
    Rails.logger.debug "VoiceAnswerWorker addvoicetorecofortext: #{upload_res}"
    if upload_res['errcode'] == 0
      res = nil
      loop do
        res = Wechat.api(:svca).queryrecoresultfortext(voice_id)
        Rails.logger.debug "VoiceAnswerWorker queryrecoresultfortext: #{res}"
        sleep(0.5)
        break if res['is_end'] == true
      end
      question = res['result']
      if Current.user.present?
        openid = Current.user.email.split('@')[0]
        if question.present?
          Wechat.api.custom_message_send Wechat::Message.to(openid).text("您问：#{question}")
          answer_via_wechat_api(question, openid)
        else
          Wechat.api.custom_message_send Wechat::Message.to(openid).text("微信智聆没听出来。。(#{voice_id})")
        end
      else
        # User never login in cybros
      end
    end
  end

  private

  def answer_via_wechat_api(content, openid)
    ks = Company::Knowledge.answer(content)
    if ks.present?
      k = ks.first
      Current.user = User.find_by email: "#{openid}@thape.com.cn"
      Rails.logger.debug "User name: #{openid}, User company: #{Current.user.user_company_short_name}, "
      "department: #{Current.user.user_department_name}, User voice question: #{content} "
      "Question category: #{k.category_1}, answered as question: #{k.question}"
      if k.can_show_text_directly? && ks.count == 1
        Wechat.api.custom_message_send Wechat::Message.to(openid).text k.answer.to_plain_text
      else
        host = CybrosCore::Application.config.action_mailer.default_url_options[:host]
        answer_articles = ks.each_with_object([]) do |q, memo|
          memo << { title: q.question, description: "类别：#{q.category_1} #{q.category_2} #{q.category_3}",
          pic_url: ActionController::Base.helpers.asset_url(Company::KnowledgeImages.random_one, type: :image),
          url: Rails.application.routes.url_helpers.company_home_knowledge_url(q, host: host) }
        end
        Wechat.api.custom_message_send Wechat::Message.to(openid).news answer_articles
      end
    else
      if Current.user.present?
        Current.user.pending_questions.create(question: content)
      else
        Rails.logger.debug "User question not answer: #{content}"
      end
      Wechat.api.custom_message_send Wechat::Message.to(openid).text Company::Knowledge.no_answer_content
    end
  end
end
