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
          currencies = @store["currencies"] || []
          @store[date_key(date)] = rates
          rates.keys.map { |currency| currencies << currency }
          @store["currencies"] = currencies.uniq
        end
      end

      def currencies_available
        currencies = @store.transaction { @store["currencies"] }
        update! if currencies.nil?
        @store.transaction do
          @store["currencies"]
        end
      end

    end
  end
end
