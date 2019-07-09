class VoiceAnswerJob < ApplicationJob
  queue_as :default

  def perform(voice_id)
    Rails.logger.debug "VoiceAnswerJob got: #{voice_id}"
  end
end
