require 'redis'
module EuropaRates
  module Stores
    class RedisStore < EuropaRates::Store

      def initialize
        # if we do not wish to require redis as a dependency, we can test if it is installed
        # raise "Redis gem is not available" unless !!Gem::Specification.all.detect{|g| g.name == "redis"}
        require 'redis'
        @store = Redis.new(:url => EuropaRates.configuration.redis_url)
      end

      def rates_at(date=Date.today)
        result = @store.hgetall(date_key(date))
        raise NoDataAvailableError if result.nil?
        result
      end

      def set_rates_for(date, rates)
        rates.each do |symbol, rate|
          key = date_key(date)
          @store.hset(key, symbol, rate)
          @store.sadd("currencies", symbol)
        end
      end

      def currencies_available
        if @store.smembers("currencies").empty?
          update!
        end
        @store.smembers("currencies")
      end

    end
  end
end
