class FlickrPhoto
  attr_accessor :id, :flickr_data, :title, :description, :ownername, :uploaded_at
  
  def self.list_for_accounts(accounts, options={})
    set_flickr_auth
    
    options[:per_page] ||= 20
    
    @raw_photos = []
    accounts.each do |nsid|
      @account_photos = Rails.cache.fetch("flickr/recent/#{nsid}/pp/#{options[:per_page]}", :expires_in => 1.hour, :race_condition_ttl => 1.hour) do
        puts "ACCOUNT: #{nsid}"
        if nsid =~ /@/
          begin
            flickr.people.getPublicPhotos(:user_id => nsid, :per_page => options[:per_page], :extras => "description,owner_name,date_upload")
          rescue Exception => e
            logger.info "Can't get photos for Flickr account '#{nsid}': #{e}"
            []
          end
        else
          []
        end
      end
      
      @account_photos.each {|p| @raw_photos << p}
    end
    
    # Sort all the photos together and make them helpful objects
    @raw_photos.sort_by {|p| p.dateupload}.reverse.map {|p| self.new(p)}
  end
    
  def self.find_account_id(url, account)
    Rails.cache.fetch("flickr/account_id/#{account}", :expires_in => 1.day, :race_condition_ttl => 1.hour) do
      set_flickr_auth
      
      logger.info "Looking up account #{account} by url..."
      begin
        person = flickr.urls.lookupUser(:url => url)
        person.id
      rescue Exception => e
        logger.info "Can't find Flickr account '#{url}': #{e}"
        # do nothing for this account
        nil
      end
    end
  end
  
  def initialize(flickr_data)
    self.flickr_data = flickr_data
    self.id = flickr_data['id']
    self.title = flickr_data['title']
    if flickr_data['description'] && flickr_data['description'] != flickr_data['title']
      self.description = flickr_data['description']
    else
      self.description = ''
    end
    self.ownername = flickr_data['ownername']
    self.uploaded_at = Time.at(flickr_data['dateupload'].to_i)
  end
  
  def img_url(options={})
    FlickRaw.url(flickr_data)
  end
  
  def page_url(options={})
    FlickRaw.url_photopage(flickr_data)
  end
  
  def profile_url(options={})
    FlickRaw.url_profile(flickr_data)
  end
  
  # Raw interactions with Flickr

  def self.set_flickr_auth
    FlickRaw.api_key = ENV['FLICKR_API_KEY']
    FlickRaw.shared_secret = ENV['FLICKR_API_SECRET']
  end
  
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

end
