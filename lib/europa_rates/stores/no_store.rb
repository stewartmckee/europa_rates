require 'yaml/store'
module EuropaRates
  module Stores
    class NoStore < EuropaRates::Store

      def initialize
        @xml = EuropaRates::Store.live_rates
      end

      def rates_at(date=Date.today)
        @xml[date]
      end

      def set_rates_for(date, rates)
        raise "Cannot set rates for live data"
      end

    end
  end
end
