require "spec_helper"

RSpec.describe EuropaRates::Stores::RedisStore do
  before(:each) do
    EuropaRates.configuration.store = "redis"
    @redis_double = instance_double("Redis")
    allow(Redis).to receive(:new).and_return(@redis_double)
    allow(@redis_double).to receive(:sadd).and_return(true)
    @store = EuropaRates::Store.factory
  end
  it "defaults to redis://localhost url" do
    expect(EuropaRates.configuration.redis_url).to eq("redis://localhost")
  end

  describe "#set_rates_for" do

    it "stores values for date" do
      expect(@redis_double).to receive("hset").with("date_2017_08_21", "USD", 1.2)
      expect(@redis_double).to receive("hset").with("date_2017_08_21", "GBP", 0.9)
      @store.set_rates_for(Date.parse("21st August 2017"), {"USD" => 1.2, "GBP" => 0.9})
    end
    it "only stores values of supplied date" do
      expect(@redis_double).to receive("hset").with("date_2017_08_21", "USD", 1.2)
      expect(@redis_double).to receive("hset").with("date_2017_08_21", "GBP", 0.9)
      @store.set_rates_for(Date.parse("21st August 2017"), {"USD" => 1.2, "GBP" => 0.9})
    end
    it "does not duplicate values for dates" do
      expect(@redis_double).to receive("hset").exactly(4).with("date_2017_08_21", anything(), anything())
      @store.set_rates_for(Date.parse("21st August 2017"), {"USD" => 1.3, "GBP" => 0.1})
      @store.set_rates_for(Date.parse("21st August 2017"), {"USD" => 1.2, "GBP" => 0.9})
    end
  end

  describe "#rates_at" do
    it "retrieves the correct rates for the date" do
      expect(@redis_double).to receive("hset").twice.with("date_2017_08_21", anything(), anything())
      expect(@redis_double).to receive("hgetall").with("date_2017_08_21").and_return({"USD" => 1.3, "GBP" => 0.1})
      @store.set_rates_for(Date.parse("21st August 2017"), {"USD" => 1.3, "GBP" => 0.1})
      expect(@store.rates_at(Date.parse("21st August 2017"))).to eq({"USD" => 1.3, "GBP" => 0.1})
    end
    it "defaults to todays date" do
      today_date_key = "date_#{Date.today.strftime("%Y_%m_%d")}"
      expect(@redis_double).to receive("hset").twice.with(today_date_key, anything(), anything())
      expect(@redis_double).to receive("hgetall").with(today_date_key).and_return({"USD" => 1.3, "GBP" => 0.1})
      @store.set_rates_for(Date.today, {"USD" => 1.3, "GBP" => 0.1})
      expect(@store.rates_at).to eq({"USD" => 1.3, "GBP" => 0.1})
    end

    it "raises error if no data available" do
      today_date_key = "date_#{Date.today.strftime("%Y_%m_%d")}"
      expect(@redis_double).to receive("hgetall").with(today_date_key).and_return(nil)
      expect{@store.rates_at}.to raise_error(EuropaRates::NoDataAvailableError)
    end

  end
end
