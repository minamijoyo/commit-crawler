require 'octokit'

# GitHub API access token must be exported
access_token = ENV['GITHUBAPI_ACCESS_TOKEN']
raise "GITHUBAPI_ACCESS_TOKEN must be exported !!" if access_token.nil?

# Octokit initialization
client = Octokit::Client.new(:access_token => access_token)
raise "Octokit initialization error" if client.nil?

# Octokit setting
client.auto_paginate = true

# check the current rate limit before call API
sleep 60 unless client.rate_limit.remaining

# search popular repositories
search_results = client.search_repos('stars:>10000', :per_page => 100)
repos = search_results.items.map(&:full_name)

# for each repository
repos.each do |repo|
  # check the current rate limit before call API
  sleep 60 unless client.rate_limit.remaining

  # get commits list on the repository
  commits = client.commits(repo, :per_page => 100)

  # for each commit
  commits.each do |commit|
    sha = commit[:sha]
    message = commit[:commit][:message]
    puts "#{repo}, #{sha}, #{message}"
  end
end
