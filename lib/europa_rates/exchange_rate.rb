module EuropaRates
  class ExchangeRate

    def initialize(currency_store = Store.factory)
      @currency_store = currency_store
    end

    def rate(options={})
      raise ":date is required" unless options.has_key?(:date)
      raise ":counter is required" unless options.has_key?(:counter)
      raise ":base is required" unless options.has_key?(:base)

      rates = @currency_store.rates_at(options[:date])
      raise NoDataAvailableError if rates == {}
      base_rate = rates[options[:base]].to_f
      counter_rate = rates[options[:counter]].to_f
      (1.0/base_rate) * counter_rate
    end

    def self.at(date, from, to)
      ExchangeRate.new.rate(:date => date, :base => from, :counter => to)
    end

    def currencies_available
      @currency_store.currencies_available
    end
  end
end
