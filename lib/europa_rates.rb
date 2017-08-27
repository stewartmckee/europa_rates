require "europa_rates/version"
require "europa_rates/configuration"
require "europa_rates/exchange_rate"
require "europa_rates/store"
require "europa_rates/stores/file_store"
require "europa_rates/stores/redis_store"

require "europa_rates/errors/invalid_store_error"
require "europa_rates/errors/no_data_available_error"

module EuropaRates
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
