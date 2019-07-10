class VoiceAnswerWorker
  include Sidekiq::Worker

  def perform(voice_id, user_id)
    Rails.logger.debug "VoiceAnswerWorker got: #{voice_id} and #{user_id}"
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
      ask_user = User.find user_id
      if ask_user.present?
        openid = ask_user.email.split('@')[0]
        if question.present?
          Wechat.api.custom_message_send Wechat::Message.to(openid).text(question)
        else
          Wechat.api.custom_message_send Wechat::Message.to(openid).text("微信智聆没听出来。。(#{voice_id})")
        end
      end
    end
  end
end
