module Company
  class Knowledge < ApplicationRecord
    has_rich_text :answer

    def self.answer(question)
      question_word = Current.jieba_keyword.extract(question, 2)
      qw1 = question_word.collect(&:first).first
      qw1 = user_synonym.fetch(qw1, qw1)
      qw2 = question_word.collect(&:first).second
      qw2 = user_synonym.fetch(qw2, qw2)
      ans = if qw2.present?
        policy_scope(Company::Knowledge).where('question LIKE ?', "%#{qw1}%#{qw2}%").or(policy_scope(Company::Knowledge).where('question LIKE ?', "%#{qw2}%#{qw1}%"))
      else
        policy_scope(Company::Knowledge).where('question LIKE ?', "%#{qw1}%")
      end.limit(2)
      if ans.count > 1
        if ans.first.question.similar(question) < ans.second.question.similar(question)
          ans.second
        else
          ans.first
        end
      elsif ans.count == 1
        ans.first
      else
        policy_scope(Company::Knowledge).where('question LIKE ?', "%#{qw1}%").first
      end
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
  end
end
