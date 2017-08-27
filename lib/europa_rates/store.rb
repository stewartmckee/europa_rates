

module EuropaRates
  class Store

    def initialize(options={})
      @options = options
    end

    def self.factory
      if EuropaRates.configuration.store.to_s == "redis"
        EuropaRates::Stores::RedisStore.new
      elsif EuropaRates.configuration.store.to_s == "file"
        EuropaRates::Stores::FileStore.new
      else
        raise EuropaRates::InvalidStoreError, "Invalid store type #{EuropaRates.configuration.store.to_s}"
      end
    end

    def self.update!()
      uri = URI.parse(EuropaRates.configuration.url)
      session = Net::HTTP.new(uri.host, uri.port)
      headers = {}
      res = session.start do |http|
        http.get(request_url, headers)
      end
      @store = CurrencyStore.get
    end

    private
    def date_key(date)
      "date_#{date.strftime("%Y_%m_%d")}"
    end

  end
end
