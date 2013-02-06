class FlickrController < ApplicationController
  layout 'flickr'
  
  def show
    @photos = []
    page_size = params[:page_size] || 100
    
    account_options = {:service_id => 'flickr'}
    registry = Registry::Client.new
    @registry_accounts = registry.accounts(account_options).map do |account|
      # Turn the Flickr URL into a standard ID
      FlickrPhoto.find_account_id(account['service_url'], account['account'])
    end
    
    # registry_accounts = ["51986662@N05", "51009184@N06", "46577594@N04"]
    
    all_photos = FlickrPhoto.list_for_accounts(@registry_accounts)
    
    @photo_count = all_photos.count
    
    # Cheap paging through an assumed-large dataset
    @this_page = params[:page].present? ? params[:page].to_i : 1
    @next_page = @this_page + 1
    @prev_page = @this_page - 1
    offset = (@this_page - 1) * page_size 
    @photos = all_photos[offset, page_size]
  end
  
end
