# commit-messages

Crawler for GitHub commit messages

This is a crawler program which collects commit messages on the GitHub popular repositories.

## How To Use
1. Get your access token for GitHub API.  
see: Creating an access token for command-line use  
 https://help.github.com/articles/creating-an-access-token-for-command-line-use/
2. Git clone and bundle.
```
$ git clone https://github.com/minamijoyo/commit-messages
$ cd commit-messages
$ bundle install
```
3. Export your access token to environment valiable.
```
$ echo "export GITHUBAPI_ACCESS_TOKEN=xxxxx" > githubapi.conf
$ source githubapi.conf
```
4. Run the crawler.
```
$ ruby crawler.rb
```
The results will be "commits.txt".
