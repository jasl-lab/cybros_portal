namespace :knowledge do
  desc 'Match knowledge question based on input sentence'
  task :match, [:sentence] => [:environment] do |task, args|
    question = args[:sentence]
    puts Company::Knowledge.answer(question)&.question
  end

  desc 'Update the knowledge according to CSV file'
  task :update_category, [:csv_file_path] => [:environment] do |task, args|
    csv_file_path = args[:csv_file_path]
    CSV.foreach(csv_file_path, headers: true) do |row|
      id = row['ID']
      c1 = row['类别1']
      c2 = row['类别2']
      c3 = row['类别3']
      q = row['问题']
      k = Company::Knowledge.find id
      puts "Original  #{id}, c1: #{k.category_1}, c2: #{k.category_2}, c3: #{k.category_3}, q: #{k.question}"
      puts "Change to #{id}, c1: #{c1}, c2: #{c2}, c3: #{c3}, q: #{q}"
      k.update(category_1: c1, category_2: c2, category_3: c3, question: q)
    end
  end
end
