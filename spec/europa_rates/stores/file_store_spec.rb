require "spec_helper"

RSpec.describe EuropaRates::Stores::FileStore do

  it "defaults to store.yaml filename" do
    expect(EuropaRates.configuration.file_path).to eq("store.yaml")
  end

  describe "#set_rates_for" do
    before(:each) do
      EuropaRates.configuration.store = "file"
      @yaml_store = instance_double("YAML::Store")
      allow(YAML::Store).to receive(:new).and_return(@yaml_store)
      allow(@yaml_store).to receive(:transaction).and_yield

      @store = EuropaRates::Store.factory
    end

    it "stores values for date" do
      expect(@yaml_store).to receive("[]=").with("date_2017_08_21", {"USD" => 1.2, "GBP" => 0.9})
      @store.set_rates_for(Date.parse("21st August 2017"), {"USD" => 1.2, "GBP" => 0.9})
    end
    it "only stores values of supplied date" do
      expect(@yaml_store).to receive("[]=").with("date_2017_08_21", {"USD" => 1.2, "GBP" => 0.9})
      @store.set_rates_for(Date.parse("21st August 2017"), {"USD" => 1.2, "GBP" => 0.9})
    end
    it "does not duplicate values for dates" do
      expect(@yaml_store).to receive("[]=").twice.with("date_2017_08_21", anything())
      @store.set_rates_for(Date.parse("21st August 2017"), {"USD" => 1.3, "GBP" => 0.1})
      @store.set_rates_for(Date.parse("21st August 2017"), {"USD" => 1.2, "GBP" => 0.9})
    end
  end

  describe "#rates_at" do
    before(:each) do
      EuropaRates.configuration.store = "file"
      @store = EuropaRates::Store.factory
    end
    it "retrieves the correct rates for the date" do
      @store.set_rates_for(Date.today, {"USD" => 1.1, "GBP" => 0.3})
      @store.set_rates_for(Date.today - 1, {"USD" => 1.2, "GBP" => 0.2})
      @store.set_rates_for(Date.today - 2, {"USD" => 1.3, "GBP" => 0.1})

      expect(@store.rates_at(Date.today - 1)).to eq({"USD" => 1.2, "GBP" => 0.2})
    end
  end

end
