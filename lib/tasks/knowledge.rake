namespace :knowledge do
  desc 'Match knowledge question based on input sentence'
  task :match, [:sentence] => [:environment] do |task, args|
    question = args[:sentence]
    puts Company::Knowledge.answer(question)&.question
  end
end
