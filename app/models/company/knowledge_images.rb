# frozen_string_literal: true

module Company
  class KnowledgeImages
    def self.random_one
      @images ||= Rails.root.join('public', 'images', 'weixin').children(false)
      random_image = @images.sample.basename.to_s
      "weixin/#{random_image}"
    end
  end
end
