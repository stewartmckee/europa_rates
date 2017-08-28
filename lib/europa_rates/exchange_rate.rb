module EuropaRates
  class ExchangeRate

    def initialize(currency_store = Store.factory)
      @currency_store = currency_store
    end

    def rate(options={})
      raise ":date is required" unless options.has_key?(:date)
      raise ":counter is required" unless options.has_key?(:counter)
      raise ":base is required" unless options.has_key?(:base)

      base_rate = @currency_store.rates_at(options[:date])[options[:base]].to_f
      counter_rate = @currency_store.rates_at(options[:date])[options[:counter]].to_f
      (1.0/base_rate) * counter_rate
    end

    def self.at(date, from, to)
      ExchangeRate.new.rate(:date => date, :base => from, :counter => to)
    end
  end
end
