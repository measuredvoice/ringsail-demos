# encoding: utf-8

namespace :demo do
  desc "Update lists on the @USAgov account"
  task :update_usagov_lists => :environment do
    puts "Updating USAgov lists on Twitter..."
    lists = [
      {:name => 'education', :options => {:agency_id => 'ed'}},
      {:name => 'agriculture', :options => {:agency_id => 'usda'}},
      {:name => 'embassies', :options => {:tag => 'embassy'}},
      {:name => 'business', :options => {:tag => 'business'}},
      {:name => 'state', :options => {:agency_id => 'state'}},
      {:name => 'treasury', :options => {:agency_id => 'treasury'}},
      {:name => 'defense', :options => {:agency_id => 'defense'}},
      {:name => 'justice', :options => {:agency_id => 'justice'}},
      {:name => 'interior', :options => {:agency_id => 'interior'}},
      {:name => 'usda', :options => {:agency_id => 'usda'}},
      {:name => 'commerce', :options => {:agency_id => 'commerce'}},
      {:name => 'labor', :options => {:agency_id => 'labor'}},
      {:name => 'hhs', :options => {:agency_id => 'hhs'}},
      {:name => 'hud', :options => {:agency_id => 'hud'}},
      {:name => 'dot', :options => {:agency_id => 'dot'}},
      {:name => 'energy', :options => {:agency_id => 'energy'}},
      {:name => 'ed', :options => {:agency_id => 'ed'}},
      {:name => 'va', :options => {:agency_id => 'va'}},
      {:name => 'dhs', :options => {:agency_id => 'dhs'}},
      {:name => 'nasa', :options => {:agency_id => 'nasa'}},
    ]
        
    Twitter.configure do |config|
      config.consumer_key = ENV['TWITTER_CLIENT_KEY']
      config.consumer_secret = ENV['TWITTER_CLIENT_SECRET']
      config.oauth_token = ENV['TWITTER_USER_KEY']
      config.oauth_token_secret = ENV['TWITTER_USER_SECRET']
    end
            
    lists.each do |list|
      update_twitter_list(list)
      
      # Spread these out over time to avoid Twitter API rate limits
      puts "Pausing to let the Twitter API catch up..."
      sleep 1.minute
      puts "proceeding."
    end
  end
  
  desc "Update lists on the @GobiernoUSA account"
  task :update_gobiernousa_lists => :environment do
    puts "Updating GobiernoUSA lists on Twitter..."
    lists = [
      {:name => 'español', :options => {:tag => 'espanol'}},
    ]
        
    Twitter.configure do |config|
      config.consumer_key = ENV['GOB_TWITTER_CLIENT_KEY']
      config.consumer_secret = ENV['GOB_TWITTER_CLIENT_SECRET']
      config.oauth_token = ENV['GOB_TWITTER_USER_KEY']
      config.oauth_token_secret = ENV['GOB_TWITTER_USER_SECRET']
    end
            
    lists.each do |list|
      update_twitter_list(list)
      
      # Spread these out over time to avoid Twitter API rate limits
      puts "Pausing to let the Twitter API catch up..."
      sleep 1.minute
      puts "proceeding."
    end
  end

  desc "Update lists on a test account"
  task :update_test_lists => :environment do
    puts "Updating test lists on Twitter..."
    lists = [
      {:name => 'arbitrary-name-really', :options => {:language => 'Polish'}},
    ]
        
    Twitter.configure do |config|
      config.consumer_key = ENV['TEST_TWITTER_CLIENT_KEY']
      config.consumer_secret = ENV['TEST_TWITTER_CLIENT_SECRET']
      config.oauth_token = ENV['TEST_TWITTER_USER_KEY']
      config.oauth_token_secret = ENV['TEST_TWITTER_USER_SECRET']
    end
            
    lists.each do |list|
      update_twitter_list(list)
      
      # Spread these out over time to avoid Twitter API rate limits
      puts "Pausing to let the Twitter API catch up..."
      sleep 20.seconds
      puts "proceeding."
    end
  end

  desc "Update all lists on Twitter"
  task :update_lists => [:update_usagov_lists, :update_gobiernousa_lists] do
    puts "All lists updated."
  end
end

def update_twitter_list(list)
  puts "Updating list '#{list[:name]}'..."
  
  # Get the list on Twitter, or create it
  begin
    puts "  Checking if list '#{list[:name]}' exists..."
    twitter_list = Twitter.list(list[:name])
    puts "  The list exists."
  rescue Twitter::Error::NotFound
    puts "    The list #{list[:name]} does not exist. Creating it..."
    twitter_list = Twitter.list_create(list[:name], :description => "")
    puts "    list created."        
  end
  
  # Get all the current members of the list
  existing_members = Twitter.list_members(list[:name]).map do |member|
    member.screen_name.downcase
  end
  puts "  #{existing_members.count} accounts are on the list."
  
  # Get the accounts that should be on the list
  account_options = list[:options].merge(:service_id => 'twitter')
  registry = Registry::Client.new
  registry_accounts = registry.accounts(account_options).map do |account|
    account['account'].downcase
  end
  puts "  #{registry_accounts.count} accounts should be on the list."
  
  # Remove any excess accounts from the list
  # (Up to 30 at a time. The Twitter API doesn't like more, 
  # and we'll catch the rest when on the next run.)
  to_remove = (existing_members - registry_accounts).slice(0,30)
  if to_remove.count > 0
    puts "  Removing #{to_remove.count} accounts from the list..."
    Twitter.list_remove_members(list[:name], to_remove)
    puts "  done removing."
  else
    puts "  No accounts to remove."
  end
  
  # Add any new accounts to the list
  # (Up to 30 at a time. The Twitter API doesn't like more, 
  # and we'll catch the rest when on the next run.)
  to_add = (registry_accounts - existing_members).slice(0,30)
  if to_add.count > 0
    puts "  Adding #{to_add.count} accounts to the list..."
    puts "    (#{to_add.join(', ')})"
    Twitter.list_add_members(list[:name], to_add)
    puts "  done adding."
  else
    puts "  No accounts to add."
  end
  
  puts "...done."
end
