module Company
  class Knowledge < ApplicationRecord
    has_rich_text :answer

    def self.answer(question)
      question_word = Current.jieba_keyword.extract(question, 2)
      qw1 = question_word.collect(&:first).first
      qw2 = question_word.collect(&:first).second
      ans = if qw2.present?
        Company::Knowledge.where('question LIKE ?', "%#{qw1}%#{qw2}%").or(Company::Knowledge.where('question LIKE ?', "%#{qw2}%#{qw1}%"))
      else
        Company::Knowledge.where('question LIKE ?', "%#{qw1}%")
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
        Company::Knowledge.where('question LIKE ?', "%#{qw1}%").first
      end
    end
  end
end
