# Registry API demonstrations

Quick demos of the Social Media Registry. (See registry.usa.gov for the API.)

## Why Rails?

These demos (loosely) use Ruby on Rails. The demos may or may not have an actual website component, but Rails offers a bunch of design defaults that help build demos like these quickly.

## Installation

Check out these demos on a server with Ruby 1.9, Rails 3, and Bundler installed.

    git clone git://github.com/measuredvoice/ringsail-demos.git

Use Bundler to update the gems these demos need:

    cd ringsail-demos
    bundle install --deployment --without development test

Copy the example secrets file, then edit it to add your API keys.
    
    cp config/too_many_secrets.example.rb config/too_many_secrets.rb
    vi config/too_many_secrets.rb

Do the same with the database configuration file:

    cp config/database.example.yml config/database.yml
    vi config/database.yml

## Running a demo

List the demo tasks available. 

    RAILS_ENV=production bundle exec rake -T |grep demo

Pass the appropriate task name to Rake. For example:

    RAILS_ENV=production bundle exec rake demo:update_lists

