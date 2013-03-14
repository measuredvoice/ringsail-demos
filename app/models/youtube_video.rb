class YoutubeVideo
  attr_accessor :id, :youtube_data, :title, :description, :ownername, :uploaded_at, :img_url, :page_url, :preview_frames
  
  def self.list_for_accounts(accounts, options={})    
    options[:per_page] ||= 20
    
    @raw_videos = []
    accounts.each do |username|
      logger.info "ACCOUNT: #{username}"
      @account_videos = Rails.cache.fetch("youtube/recent/#{username}/pp/#{options[:per_page]}", :expires_in => 6.hours, :race_condition_ttl => 5.minutes) do
        logger.info "-- cache miss --"
        begin
          client.videos_by(:user => username, :per_page => options[:per_page]).videos
        rescue Exception => e
          logger.info "Can't get videos for Youtube account '#{username}': #{e}"
          []
        end
      end
      
      @account_videos.each {|v| @raw_videos << v}
    end
    
    # Sort all the videos together and make them helpful objects
    @raw_videos.sort_by {|v| v.uploaded_at}.reverse.map {|v| self.new(v)}
  end
    
  def self.client
    @client ||= YouTubeIt::Client.new(:dev_key => ENV['YOUTUBE_API_KEY'])
  end
  
  def client
    @client ||= YouTubeIt::Client.new(:dev_key => ENV['YOUTUBE_API_KEY'])
  end
  
  def initialize(youtube_data)
    self.youtube_data = youtube_data
    self.id = youtube_data.video_id
    self.title = youtube_data.title
    self.description = youtube_data.description
    self.ownername = youtube_data.author.name
    self.uploaded_at = youtube_data.uploaded_at
    self.img_url = youtube_data.thumbnails.second.url
    self.page_url = youtube_data.player_url
    
    # These three thumbnails can be rotated for a pseudo-preview
    self.preview_frames = youtube_data.thumbnails[3..5].map {|t| t.url}
  end
  
  def profile_url
    "http://youtube.com/#{ownername}"
  end
    
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

end
