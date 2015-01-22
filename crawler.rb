require 'octokit'

client = Octokit::Client.new(:access_token => ENV['GITHUBAPI_ACCESS_TOKEN'])
client.auto_paginate = true

repo = client.repo 'minamijoyo/sample_app'
commits = client.commits repo.full_name

commits.each do |commit|
  sha = commit[:sha]
  message = commit[:commit][:message]
  puts "#{sha}, #{message}"
end
