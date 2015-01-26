# coding: utf-8
require 'octokit'

puts "Start initialization"

# no buufering for stdout
$stdout.sync = true

# GitHub API access token must be exported
access_token = ENV['GITHUBAPI_ACCESS_TOKEN']
raise "GITHUBAPI_ACCESS_TOKEN must be exported !!" if access_token.nil?

# Octokit initialization
client = Octokit::Client.new(:access_token => access_token)
raise "Octokit initialization error" if client.nil?

# Octokit setting
client.auto_paginate = true

# print login user
puts "Login user: #{client.user.login}"

# search popular repositories
puts "Search repositories on GitHub"
search_results = client.search_repos('stars:>10000', :per_page => 100)
repos = search_results.items.map(&:full_name)
puts "Target repositories: #{repos}"

# Open file for output
File.open("commits.txt", "w") do |file|
  # no buffering for the output file
  file.sync = true

  # for each repository
  repos.each do |repo|

    # get commits list on the repository
    puts "#{Time.now}: Get commit messages on github:#{repo}, rate limit: #{client.rate_limit}"
    commits_url = "https://api.github.com/repos/#{repo}/commits"

    # for each page
    client.paginate(commits_url, :per_page => 100) do |data, last_response|
      commits = data
      # for each commit
      commits.each do |commit|
        sha = commit[:sha]
        message = commit[:commit][:message].gsub(/(\r\n|\r|\n)/," ")
        # write the result to output file
        file.puts "#{repo}, #{sha}, #{message}"
      end

      # check the current rate limit and sleep
      until client.rate_limit.remaining do
        puts "current rate limit: #{client.rate_limit}"
        reset_in = client.rate_limit.resets_in
        puts "rate limit sleep in #{reset_in}"
        sleep reset_in
      end

      # sleep each page
      sleep 1

    end
  end
end
