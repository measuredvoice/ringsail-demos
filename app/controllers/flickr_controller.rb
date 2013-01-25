class FlickrController < ApplicationController
  layout 'flickr'
  
  def show
    @photos = []
    
    account_options = {:service_id => 'flickr'}
    registry = Registry::Client.new
    registry_accounts = registry.accounts(account_options).map do |account|
      account['account']
    end
    
    # registry_accounts = ["acusgov", "51986662@N05", "51009184@N06", "46577594@N04"]
    
    @photos = FlickrPhoto.list_for_accounts(registry_accounts)
  end
  
end
