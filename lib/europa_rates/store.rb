
require 'net/http'
require 'nokogiri'

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
      elsif EuropaRates.configuration.store.to_s == "no_store"
        EuropaRates::Stores::NoStore.new
      else
        raise EuropaRates::InvalidStoreError, "Invalid store type #{EuropaRates.configuration.store.to_s}"
      end
    end

    def self.rate_document
      uri = URI.parse(EuropaRates.configuration.url)
      session = Net::HTTP.new(uri.host, uri.port)
      headers = {}
      res = session.start do |http|
        http.get(uri, headers)
      end
      Nokogiri::XML(res.body)
    end

    def self.live_rates
      rates = {}
      begin
        rate_document.xpath("/gesmes:Envelope//xmlns:Cube[@time]").each do |date_cube|
          date = Date.parse(date_cube["time"])
          rates[date] = {}
          date_cube.xpath("xmlns:Cube[@rate]").each do |rate_cube|
            rates[date][rate_cube[:currency]] = rate_cube[:rate].to_f
          end
        end
      rescue
        puts "Error retrieving data"
      end
      rates
    end

    def set_rates_for(date, rates)
      rates.each do |symbol, rate|
        @store.hset(date_key(date), symbol, rate)
      end
    end

    def update!
      current_rates = EuropaRates::Store.live_rates
      current_rates.keys.map{|date| set_rates_for(date, current_rates[date]) }
    end


    private
    def date_key(date)
      "date_#{date.strftime("%Y_%m_%d")}"
    end

  end
end
