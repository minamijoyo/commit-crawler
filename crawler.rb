# coding: utf-8
require 'octokit'

##
# Crawler class for GitHub
#
class Crawler

  def initialize(opts = {})
    @client = Octokit::Client.new(:access_token => opts[:access_token])
    raise "Octokit initialization error" if @client.nil?
    @file = opts[:file]

    puts "Login user: #{@client.user.login}"
  end

  def crawl
    puts "Search repositories on GitHub"

    # search for popular repositories
    @repos = search_repos('stars:>10000')
    puts "Target repositories: #{@repos}"

    # crawl for each repository
    @repos.each { |repo| crawl_repo repo }
  end

  private

    def search_repos(query)
      @client.auto_paginate = true
      search_results = @client.search_repos(query, :per_page => 100)
      @client.auto_paginate = false
      # extract repo's full_name
      repos = search_results.items.map(&:full_name)
    end

    def crawl_repo(repo)
      # get commits list on the repository
      commits_list(repo)
    end

    def commits_list(repo)
      puts "#{Time.now}: Get commit messages on github:#{repo}, rate limit: #{@client.rate_limit}"

      # for rate limitaion of GitHub API
      check_rate_limit_and_sleep

      # for first page
      first_response = @client.commits(repo, :per_page => 100)
      commits = parse_commits(repo, first_response)
      puts_file commits

      # for pagination
      last_response = @client.last_response
      while last_response && last_response.rels[:next]
        last_response = last_response.rels[:next].get
        last_commits = parse_commits(repo, last_response.data)
        puts_file last_commits

        # for adjust request speed on each page
        sleep 1
      end

    end

    def parse_commits(repo, commits_response)
      commits_response.map do |commit|
        { :repo => repo,
          :sha => commit[:sha],
          :message => commit[:commit][:message].gsub(/(\r\n|\r|\n)/," ")
        }
      end
    end

    def puts_file(commits)
      commits.each do |commit|
        @file.puts "#{commit[:repo]}, #{commit[:sha]}, #{commit[:message]}"
      end
    end

    def check_rate_limit_and_sleep
      limit = @client.rate_limit
      until limit.remaining do
        puts "current rate limit: #{limit}"
        reset_in = limit.resets_in
        puts "rate limit sleep in #{reset_in}"
        sleep reset_in
      end
    end
end

##
# Main
#
puts "Start initialization"

# GitHub API access token must be exported
access_token = ENV['GITHUBAPI_ACCESS_TOKEN']
raise "GITHUBAPI_ACCESS_TOKEN must be exported !!" if access_token.nil?

# results file name
filename = "commits.txt"

# Open file for results
File.open(filename, "w") do |file|
  # set no buffering
  file.sync = true
  $stdout.sync = true

  # initialize crawler
  crawler = Crawler.new({:access_token => access_token,
                          :file => file})
  # run crawl main
  crawler.crawl

end

puts "End of program"
