# README

To use this app, you must have Sidekiq running alongside the Rails server. Follow these steps:
  - bundle install
  - run command `sidekiq` in terminal

This app uses a personal API key to authenticate against the Meetup API. Normally the encrypted credentials file would be checked into the repository. However, because you will be using your own key, you will be adding both the credentials file and the master key file. There is a good overview of the process here: https://medium.com/cedarcode/rails-5-2-credentials-9b3324851336

To add new encrypted credentials:
  - delete the existing file `config/credentials.yml.enc`
  - log into your meetup.com account and retrieve your personal API key
  - run the command `EDITOR=vim rails credentials:edit`--you may use another editor if you wish. This will add a new credentials file and generate a master key for your install of the app.
  - after opening the credentials file, enter your personal key under meetup.api_key, in the yml format:
    `meetup:
      api_key: 12345`

Lastly, you must have Redis installed and running. See here: https://redis.io/topics/quickstart
One easy option is to install always have redis running by using Homebrew's `brew services`.
