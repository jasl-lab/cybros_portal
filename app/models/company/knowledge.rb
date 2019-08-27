module Company
  class Knowledge < ApplicationRecord
    KNOWLEDGE_MAINTAINER = %w(忻琳 聂玲玲 冯可 季建杰 柳怡帆 吴婷 郑贤来 邢侃 袁士捷 张雨 龙默涵 杨琼 季建杰 龚筑媛 吴冬丹 王婷玉 高於 冷文欣).freeze
    attr_accessor :q_user_id

    NO_ANSWER_FOUND_1 = %w(我还小~还不知道呢 你。。。你问到我了 嗯，这个问题有意思).freeze
    NO_ANSWER_FOUND_2 = %w(我要去学习一下 我得去问问专家 哈哈哈哈哈哈（手动尴尬）).freeze
    NO_ANSWER_FOUND_3 = %w(等我学会了再问我吧，你也可以点击查询更多看看有没有你想要的答案哦).freeze

    has_rich_text :answer

    def self.answer(question)
      direct_question = Company::DirectQuestion.find_by(question: question)
      if direct_question.present?
        return [Company::Knowledge.find_by(question: direct_question.real_question)]
      end

      nouns = Company::Knowledge.extract_the_noun_and_verb_in_question(question)
      if nouns.count == 1
        only_noun = nouns.first
        only_noun_question = Pundit.policy_scope(Current.user, Company::Knowledge).where('question LIKE ?', "%#{only_noun}%").limit(1)
        if only_noun_question.blank?
          only_noun_in_synonym = user_synonym.fetch(only_noun, only_noun)
          only_noun_question = Pundit.policy_scope(Current.user, Company::Knowledge).where('question LIKE ?', "%#{only_noun_in_synonym}%").limit(1)
        end

        return [] if only_noun_question.blank?
      end

      question_word = Current.jieba_keyword.extract(question, 2)
      qw1 = question_word.collect(&:first).first
      qw2 = question_word.collect(&:first).second
      no_synonym_answers = search_question(qw1, qw2, question)

      return no_synonym_answers if no_synonym_answers.present?

      uqw1 = user_synonym.fetch(qw1, qw1)
      uqw2 = user_synonym.fetch(qw2, qw2)
      search_question(uqw1, uqw2, question)
    end

    def self.user_synonym
      @@h ||= {}
      return @@h if @@h.present?
      File.readlines(Rails.root.join('config', 'synonym.dict.utf8')).each do |l|
        words = l.strip.split(' ')
        to_change_word = words[0]
        words.each_with_index do |w, i|
          next if i == 0
          @@h[w] = to_change_word
        end
      end
      @@h
    end

    def self.extract_the_noun_and_verb_in_question(question)
      tags = Current.jieba_tagging.tag question
      noun_tags = tags.reject { |h| !(h.has_value?('n') || h.has_value?('v') || h.has_value?('t'))  }
      noun_tags.collect { |h| h.keys.first }
    end

    def self.knowledge_maintainers
      @knowledge_maintainers ||= KNOWLEDGE_MAINTAINER.collect do |name|
        user = User.find_by(chinese_name: name)
        next if user.blank?
        [name, user.id]
      end.reject(&:blank?)
    end

    def self.no_answer_content
      "#{NO_ANSWER_FOUND_1.sample}\r\n#{NO_ANSWER_FOUND_2.sample}\r\n#{NO_ANSWER_FOUND_3.sample}"
    end

    def can_show_text_directly?
      knowledge_images_path = Rails.root.join("public", "knowledge_images", id.to_s)
      answer.embeds_attachment_ids.blank? && !answer.to_plain_text.include?("[Image]") \
        && (!Dir.exist?(knowledge_images_path) || Dir.empty?(knowledge_images_path)) \
        && (answer.to_plain_text.length < 200)
    end

    private

    def self.search_question(qw1, qw2, user_question)
      ans = if qw2.present?
        Pundit.policy_scope(Current.user, Company::Knowledge).where('question LIKE ?', "%#{qw1}%#{qw2}%").or(Pundit.policy_scope(Current.user, Company::Knowledge).where('question LIKE ?', "%#{qw2}%#{qw1}%"))
      elsif qw1.present?
        Pundit.policy_scope(Current.user, Company::Knowledge).where('question LIKE ?', "%#{qw1}%")
      else
        Pundit.policy_scope(Current.user, Company::Knowledge).none
      end.limit(7)
      if ans.count > 1 && qw2.present?
        if ans.first.question.similar(user_question) < ans.second.question.similar(user_question)
          [ans.second]
        else
          [ans.first]
        end
      else
        ans.present? ? ans : Pundit.policy_scope(Current.user, Company::Knowledge).where('question LIKE ?', "%#{qw1}%").limit(7)
      end
    end
  end
end
