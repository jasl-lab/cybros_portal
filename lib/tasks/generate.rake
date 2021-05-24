# frozen_string_literal: true

namespace :generate do
  desc 'Generate user default name card'
  task user_default_name_card: :environment do
    User.where.not(mobile: nil, chinese_name: nil, clerk_code: nil, position_title: nil, email: nil)
      .each do |user|
      generate_name_card(user)
    end
  end

  def generate_name_card(user)
    final_image_file_name = "#{Rails.public_path}/default_name_card/#{user.clerk_code}.png"

    origin_image = MiniMagick::Image.open("#{Rails.public_path}/system/name-card.png")

    name_card_apply = NameCardApply.where(user_id: user.id, status: '同意').order(id: :desc).first

    if name_card_apply.present?
      with_name_email_mobile_web = generate_name_card_by_name_card_apply(user, name_card_apply, origin_image)
    else
      with_name_email_mobile_web = generate_name_card_by_user_profile(user, origin_image)
    end
    with_name_email_mobile_web.write(final_image_file_name)
    File.chmod(0604, final_image_file_name)
  end

  def generate_name_card_by_user_profile(user, origin_image)
    origin_image.combine_options do |c|
      c.font source_han_sans_font_path
      c.pointsize 64
      c.draw "text 120,320 '#{user.chinese_name}'"
      c.fill 'black'
    end

    with_name = origin_image.combine_options do |c|
      c.font source_han_sans_font_path
      c.pointsize 32
      c.draw "text 120,380 '#{user.position_title}'"
      c.fill 'black'
    end

    with_name_email = with_name.combine_options do |c|
      c.font source_han_sans_font_path
      c.pointsize 24
      c.draw "text 120,650 'E: #{user.email}'"
      c.fill 'black'
    end

    with_name_email_mobile = with_name_email.combine_options do |c|
      c.font source_han_sans_font_path
      c.pointsize 24
      c.draw "text 120,680 'M: #{user.mobile}'"
      c.fill 'black'
    end

    with_name_email_mobile_web = with_name_email_mobile.combine_options do |c|
      c.font source_han_sans_font_path
      c.pointsize 24
      c.draw "text 120,710 'W: https://www.thape.com/'"
      c.fill 'black'
    end
    with_name_email_mobile_web
  end

  def generate_name_card_by_name_card_apply(user, name_card_apply, origin_image)
    origin_image.combine_options do |c|
      c.font source_han_sans_font_path
      c.pointsize 64
      c.draw "text 120,260 '#{user.chinese_name} #{name_card_apply.english_name}'"
      c.fill 'black'
    end

    with_title = origin_image.combine_options do |c|
      c.font source_han_sans_font_path
      c.pointsize 32
      c.draw "text 120,320 '#{name_card_apply.department_name} #{name_card_apply.title.tr("'", '')}'"
      c.fill 'black'
    end

    with_title_english = with_title.combine_options do |c|
      c.font source_han_sans_font_path
      c.pointsize 24
      c.draw "text 120,360 '#{name_card_apply.en_department_name.tr("'", '')} #{name_card_apply.en_title.tr("'", '')}'"
      c.fill 'black'
    end

    with_title_english_professional = with_title_english.combine_options do |c|
      c.font source_han_sans_font_path
      c.pointsize 24
      c.draw "text 120,400 '#{name_card_apply.professional_title.tr("'", '')}'"
      c.fill 'black'
    end

    with_title_english_professional_english = with_title_english_professional.combine_options do |c|
      c.font source_han_sans_font_path
      c.pointsize 24
      c.draw "text 120,440 '#{name_card_apply.en_professional_title.tr("'", '')}'"
      c.fill 'black'
    end

    with_name_email = with_title_english_professional_english.combine_options do |c|
      c.font source_han_sans_font_path
      c.pointsize 24
      c.draw "text 120,650 'E: #{user.email}'"
      c.fill 'black'
    end

    with_name_email_mobile = with_name_email.combine_options do |c|
      c.font source_han_sans_font_path
      c.pointsize 24
      c.draw "text 120,680 'M: #{user.mobile}'"
      c.fill 'black'
    end

    with_name_email_mobile_web = with_name_email_mobile.combine_options do |c|
      c.font source_han_sans_font_path
      c.pointsize 24
      c.draw "text 120,710 'W: https://www.thape.com/'"
      c.fill 'black'
    end
    with_name_email_mobile_web
  end

  def source_han_sans_font_path
    if Gem::Platform.local.os == 'darwin'
      "#{Dir.home}/Library/Fonts/SourceHanSansCN-Normal.ttf"
    else
      '/usr/share/fonts/truetype/SourceHanSansCN-Normal.ttf'
    end
  end
end
