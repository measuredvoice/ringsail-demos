namespace :demo do
  desc "Update lists on the @USAgov account"
  task :update_usagov_lists => :environment do
    puts "Updating USAgov lists on Twitter..."
    registry = Registry::Client.new
    agency_details = registry.agencies_hash
    agency_keys = [
      'state',
      'treasury',
      'defense',
      'justice',
      'interior',
      'usda',
      'commerce',
      'labor',
      'hhs',
      'hud',
      'dot',
      'energy',
      'ed',
      'va',
      'dhs',
      'nasa',
    ]
        
    Twitter.configure do |config|
      config.consumer_key = ENV['TWITTER_CLIENT_KEY']
      config.consumer_secret = ENV['TWITTER_CLIENT_SECRET']
      config.oauth_token = ENV['TWITTER_USER_KEY']
      config.oauth_token_secret = ENV['TWITTER_USER_SECRET']
    end
            
    agency_keys.each do |agency_id|
      details = agency_details[agency_id]
      agency_name = details['agency_name']
      puts "Updating list '#{agency_id}' for the #{agency_name}..."
      
      # Get the list on Twitter, or create it
      begin
        puts "  Checking if list '#{agency_id}' exists..."
        list = Twitter.list(agency_id)
        puts "  The list exists."
      rescue Twitter::Error::NotFound
        puts "    The list #{agency_id} does not exist. Creating it..."
        list = Twitter.list_create(agency_id, :description => "Accounts managed by the #{agency_name}")
        puts "    list created."        
      end
      
      # Get all the current members of the list
      existing_members = Twitter.list_members(agency_id).map do |member|
        member.screen_name.downcase
      end
      puts "  #{existing_members.count} accounts are on the list."
      
      # Get the accounts that should be on the list
      agency_options = {:service_id => 'twitter', :agency_id => agency_id}
      registry_accounts = registry.accounts(agency_options).map do |account|
        account['account'].downcase
      end
      puts "  #{registry_accounts.count} accounts should be on the list."
      
      # Remove any excess accounts from the list
      # (Up to 30 at a time. The Twitter API doesn't like more, 
      # and we'll catch the rest when on the next run.)
      to_remove = (existing_members - registry_accounts).slice(0,30)
      if to_remove.count > 0
        puts "  Removing #{to_remove.count} accounts from the list..."
        Twitter.list_remove_members(agency_id, to_remove)
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
        Twitter.list_add_members(agency_id, to_add)
        puts "  done adding."
      else
        puts "  No accounts to add."
      end
      
      puts "...done."
      
      # Spread these out over time to avoid Twitter API rate limits
      puts "Pausing to let the Twitter API catch up..."
      sleep 1.minute
      puts "proceeding."
    end
  end
  
  desc "Update all lists on Twitter"
  task :update_lists => :update_usagov_lists do
    puts "All lists updated."
  end
end
