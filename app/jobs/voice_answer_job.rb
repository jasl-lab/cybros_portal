class VoiceAnswerJob < ApplicationJob
  queue_as :default

  def perform(voice_id, user_id)
    Rails.logger.debug "VoiceAnswerJob got: #{voice_id} and #{user_id}"
  end
end
