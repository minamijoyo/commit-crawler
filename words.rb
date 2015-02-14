# coding: utf-8

words = Hash.new(0)

open('commits.txt') do |file|
  file.each do |line|
    repo_full_name, sha, message = line.split(', ', 3)
    message.chomp!
    message.split(/\W+/).each do |word|
      if word.length > 2
        words[word.downcase] += 1
      end
    end
  end
end

words.sort_by{|word, count| [-count, word]}.each do |word, count|
  puts "#{word}, #{count}"
end
