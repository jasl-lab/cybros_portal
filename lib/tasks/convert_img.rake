# frozen_string_literal: true

namespace :convert_img do
  desc 'Decode base64 img and save in files'
  task convert_img: :environment do
    Company::Knowledge.all.each do |k|
      doc = Nokogiri::HTML(k.answer.to_s)
      divs = doc.css('.trix-content>div')
      divs.each_with_index do |div, index|
        div.css('action-text-attachment').each_with_index do |node, idx|
          dir = save_img(node, k.id, index.to_s + '_' + idx.to_s)
          if dir
            node.add_next_sibling '<figure><img src="/knowledge_images/' + dir + '"></figure>'
            node.remove
          end
        end
      end
      k.answer = doc.css('.trix-content>div').to_html
      k.save
    end
  end

  def save_img(node, id, filename)
    if node
      url = node.attr('url')
      if url.match?(/^data:image\//)
        ext = '.' + url.to_s[/\/\w*;/][1...-1]
        index = url.to_s.index(',') + 1
        FileUtils.mkdir_p(Rails.root.join('public', 'knowledge_images', id.to_s))
        tgt_dir = Rails.root.join('public', 'knowledge_images', id.to_s, filename + ext)
        File.open(tgt_dir, 'wb') do |f|
          f.write(Base64.decode64(node.attr('url').to_s[index..]))
        end
        id.to_s + '/' + filename + ext
      end
    end
  end
end
