module EuropaRates
  class ExchangeRate

    def initialize(currency_store = CurrencyStore.new)
      @currency_store = currency_store
    end

    def rate(options={})
      raise ":date is required" unless options.has_key?(:date)
      raise ":counter is required" unless options.has_key?(:counter)
      raise ":base is required" unless options.has_key?(:base)

      base_rate = @currency_store.rates_at(date)[options[:base]].to_f
      counter_rate = @currency_store.rates_at(date)[options[:counter]].to_f

      base_rate * counter_rate
    end

    def self.at(date, from, to)
      ExchangeRate.new.convert(:date => date, :base => from, :counter => to)
    end
  end
end
