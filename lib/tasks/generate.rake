# frozen_string_literal: true

namespace :generate do
  desc 'Generate user default name card'
  task user_default_name_card: :environment do
    User.where.not(mobile: nil, chinese_name: nil, clerk_code: nil, position_title: nil, email: nil).each do |user|
      generate_name_card(user)
    end
  end

  def generate_name_card(user)
    final_image_file_name = "#{Rails.public_path}/default_name_card/#{user.clerk_code}.png"

    origin_image = MiniMagick::Image.open("#{Rails.public_path}/system/name-card.png")
    origin_image.combine_options do |c|
      if Gem::Platform.local.os == "darwin"
        c.font "#{Dir.home}/Library/Fonts/SourceHanSansCN-Normal.ttf"
      else
        c.font '/usr/share/fonts/default/SourceHanSansCN-Normal.ttf'
      end
      c.pointsize 48
      c.draw "text 280,1060 '#{user.chinese_name}'"
      c.fill 'black'
    end

    origin_image.write(final_image_file_name)
    File.chmod(0604, final_image_file_name)
  end
end
