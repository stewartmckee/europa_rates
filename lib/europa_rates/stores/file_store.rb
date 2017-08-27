require 'yaml/store'
module EuropaRates
  module Stores
    class FileStore < EuropaRates::Store

      def initialize
        @store = YAML::Store.new(EuropaRates.configuration.file_path)
      end

      def rates_at(date=Date.today)
        @store.transaction do
          @store[date_key(date)]
        end
      end

      def set_rates_for(date, rates)
        @store.transaction do
          @store[date_key(date)] = rates
        end
      end

    end
  end
end
