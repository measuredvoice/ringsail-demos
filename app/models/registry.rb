module Registry
  class Client
    def initialize
      @apis_host = ENV['REGISTRY_API_HOST'] || 'http://registry.usa.gov'
    end
    
    def accounts(options={})
      Rails.cache.fetch({:type => 'registry_accounts', :options => options}, :expires_in => 1.hour, :race_condition_ttl => 5.minutes) do
        endpoint = @apis_host + '/accounts.json'
        response = JSON.parse(RestClient.get(endpoint, {:params => options}))
        accounts = response['accounts']
        if response['page_count'] > 1
          (2..response['page_count']).each do |page_number|
            accounts += JSON.parse(RestClient.get(endpoint, {:params => options.merge(:page_number => page_number)}))['accounts']
          end
        end
        accounts
      end
    end
    
    def full_accounts(options={})
      accounts.map do |a|
        get_account(a['service_url'])
      end
    end
    
    def get_account(service_url)
      endpoint = @apis_host + '/accounts/verify.json'
      options = {'service_url' => service_url}
      JSON.parse(RestClient.get(endpoint, {:params => options}))      
    end

    def agencies
      endpoint = @apis_host + '/agencies.json'
      response = JSON.parse(RestClient.get endpoint)
      agencies = response['agencies']
      
      if response['page_count'] > 1
        (2..response['page_count']).each do |page_number|
          agencies += JSON.parse(RestClient.get(endpoint, {:params => {:page_number => page_number}}))['agencies']
        end
      end
      agencies
    end

    def agencies_hash
      the_hash = {}
      agencies.each do |agency|
        the_hash[agency['agency_id']] = agency
      end
      the_hash
    end
  end  
end
