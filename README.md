# commit-messages

Crawler for GitHub commit messages

This is a crawler program which collects commit messages on the GitHub popular repositories.

## How To Use
Get your access token for GitHub API.

see: Creating an access token for command-line use  
 https://help.github.com/articles/creating-an-access-token-for-command-line-use/

Git clone and bundle.
```
$ git clone https://github.com/minamijoyo/commit-messages
$ cd commit-messages
$ bundle install
```

Export your access token to environment valiable.
```
$ echo "export GITHUBAPI_ACCESS_TOKEN=xxxxx" > githubapi.conf
$ source githubapi.conf
```

Run the crawler.
```
$ ruby crawler.rb
```
The results will be "commits.txt".
