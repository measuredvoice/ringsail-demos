class YoutubeController < ApplicationController
  layout 'youtube'

  def show
    @videos = []
    page_size = params[:page_size].to_i > 0 ? params[:page_size].to_i : 15
    account_options = {:service_id => 'youtube'}
    registry = Registry::Client.new
    @registry_accounts = registry.accounts(account_options).map do |account|
      account['account']
    end

    all_videos = YoutubeVideo.list_for_accounts(@registry_accounts)

    @video_count = all_videos.count

    # Cheap paging through an assumed-large dataset
    @this_page = params[:page].present? ? params[:page].to_i : 1
    @next_page = @this_page + 1
    @prev_page = @this_page - 1
    @total_pages = @video_count / page_size + 1
    offset = (@this_page - 1) * page_size
    @videos = all_videos[offset, page_size]

    # uncomment the next line to show g+ and tweet sharers
    @show_sharers = 1
  end
end
