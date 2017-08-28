module EuropaRates
  class Configuration
    attr_accessor :url, :store, :redis_url, :file_path

    def initialize
      self.url = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml" unless !self.url.nil?
      self.store = :file unless !self.store.nil?
      self.redis_url = "redis://localhost"
      self.file_path = "store.yaml"
    end
  end
end
