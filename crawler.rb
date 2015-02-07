# coding: utf-8
require 'octokit'

# Crawler class for GitHub
#
#
class Crawler

  # Initializes a new crawler
  #
  # @param [Hash] opts the options to initialize
  # @option opts [String] :access_token The token for GitHub API
  # @option opts [File] :file The file handle for output
  def initialize(opts = {})
    @client = Octokit::Client.new(:access_token => opts[:access_token])
    raise "Octokit initialization error" if @client.nil?
    @file = opts[:file]

    puts "Login user: #{@client.user.login}"
  end

  # Crawl to GitHub
  #
  def crawl
    puts "Search repositories on GitHub"

    # search for popular repositories
    @repos = search_repos('stars:>10000')
    puts "Target repositories: #{@repos}"

    # crawl for each repository
    @repos.each { |repo| crawl_repo repo }
  end

  private

    # Search target repositories for crawl
    #
    # @param [String] query Query keword for search
    # @return [Array<String>] An array of repo's full_name
    def search_repos(query)
      # temporary set auto_paginate to true
      @client.auto_paginate = true
      # search
      search_results = @client.search_repos(query, :per_page => 100)
      # auto_paginate off
      @client.auto_paginate = false
      # extract repo's full_name
      repos = search_results.items.map(&:full_name)
    end

    # Crawl a repository
    #
    # @param [String] repo Repository full_name such as "minamijoyo/commit_messages"
    def crawl_repo(repo)
      # get commits list on the repository
      commits_list(repo)
    end

    # Get List of commits
    #
    # @param [String] repo Repository full_name
    def commits_list(repo)
      puts "#{Time.now}: Get commit messages on github:#{repo}, rate limit: #{@client.rate_limit}"

      # check the rate limitaion of GitHub API
      check_rate_limit_and_sleep

      # for the first page
      first_response = @client.commits(repo, :per_page => 100)
      # extract necessary data from response
      commits = parse_commits(repo, first_response)
      # output to file
      puts_file commits

      # for the next page
      last_response = @client.last_response
      while last_response && last_response.rels[:next]
        # each page
        last_response = last_response.rels[:next].get
        last_commits = parse_commits(repo, last_response.data)
        puts_file last_commits

        # adjust request speed on each page
        sleep 1
      end

    end

    # Extract necessary data from response
    #
    # @param [String] repo Repository full_name
    # @param [Sawyer::Response] commits_response Response object
    # @return [Hash] A hash of commit data
    def parse_commits(repo, commits_response)
      commits_response.map do |commit|
        { :repo => repo,
          :sha => commit[:sha],
          :message => commit[:commit][:message].lines[0].chomp
        }
      end
    end

    # Write results output file
    #
    # @param [Array<Hash>] commits An array of hash which returned by parse_commits
    def puts_file(commits)
      commits.each do |commit|
        @file.puts "#{commit[:repo]}, #{commit[:sha]}, #{commit[:message]}"
      end
    end

    # check the rate limitaion of GitHub API
    #
    def check_rate_limit_and_sleep
      limit = @client.rate_limit
      # check the remaining count
      until limit.remaining do
        puts "current rate limit: #{limit}"
        # limit resets after reset_in second
        reset_in = limit.resets_in
        puts "rate limit sleep in #{reset_in}"
        # sleep until reset
        sleep reset_in
      end
    end
end

# Main
#
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
