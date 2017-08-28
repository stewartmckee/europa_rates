require "spec_helper"

RSpec.describe EuropaRates::ExchangeRate do
  describe "#at" do
    before(:each) do

      @store_double = double("EuropaRates::Store")
      allow(EuropaRates::Store).to receive(:factory).and_return(@store_double)
      allow(@store_double).to receive(:rates_at).with(Date.today).and_return({"RATE1" => 2.0, "RATE2" => 0.5 })
      allow(@store_double).to receive(:rates_at).with(Date.today-1).and_return({"RATE1" => 1.8, "RATE2" => 0.6 })
    end

    it "should get correct rates for date" do
      expect(EuropaRates::ExchangeRate.at(Date.today, "RATE1", "RATE2")).to eq(0.25)
      expect(EuropaRates::ExchangeRate.at(Date.today-1, "RATE1", "RATE2")).to eq(0.3333333333333333)
    end
    it "should calculate 1 for same rates" do
      expect(EuropaRates::ExchangeRate.at(Date.today, "RATE1", "RATE1")).to eq(1)
    end
    it "should calculate correct rate" do
      expect(EuropaRates::ExchangeRate.at(Date.today, "RATE1", "RATE2")).to eq(0.25)
    end
  end
end

# (x / rate1) * RATE2
