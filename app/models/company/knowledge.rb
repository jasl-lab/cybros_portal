module Company
  class Knowledge < ApplicationRecord
    KNOWLEDGE_MAINTAINER = %w(忻琳 聂玲玲 冯可 季建杰 柳怡帆 吴婷 郑贤来 邢侃 袁士捷 张雨 冯巧容 王玥).freeze
    attr_accessor :q_user_id
    has_rich_text :answer

    def self.answer(question)
      direct_question = Company::DirectQuestion.find_by(question: question)
      if direct_question.present?
        return [Company::Knowledge.find_by(question: direct_question.real_question)]
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

    def self.knowledge_maintainers
      @knowledge_maintainers ||= KNOWLEDGE_MAINTAINER.collect do |name|
        user = User.find_by(chinese_name: name)
        next if user.blank?
        [name, user.id]
      end.reject(&:blank?)
    end

    def answer_contain_text_only?
      answer.embeds_attachment_ids.blank? && !answer.to_plain_text.include?("[Image]")
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
