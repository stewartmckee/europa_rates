require "spec_helper"

RSpec.describe EuropaRates::Store do

  it "should default options to empty hash" do
    store = EuropaRates::Store.new
    expect(store.instance_variable_get(:@options)).to eq({})
  end
  it "should set @options to passed in object" do
    store = EuropaRates::Store.new(:test => "value")
    expect(store.instance_variable_get(:@options)).to eq({:test => "value"})
  end

  describe "factory" do
    it "should return filestore by default" do
      expect(EuropaRates::Store.factory).to be_kind_of(EuropaRates::Stores::FileStore)
    end
    it "should return filestore if file specified" do
      EuropaRates.configuration.store = "file"
      expect(EuropaRates::Store.factory).to be_kind_of(EuropaRates::Stores::FileStore)
    end
    it "should return redisstore if redis specified" do
      EuropaRates.configuration.store = "redis"
      expect(EuropaRates::Store.factory).to be_kind_of(EuropaRates::Stores::RedisStore)
    end
    it "should raise exception if invalid store specified" do
      EuropaRates.configuration.store = "invalid-value"
      expect {EuropaRates::Store.factory} .to raise_error(EuropaRates::InvalidStoreError, "Invalid store type invalid-value")
    end
  end

  describe "live_rates" do
    before(:each) do
      @doc = Nokogiri::XML("<gesmes:Envelope xmlns:gesmes=\"http://www.gesmes.org/xml/2002-08-01\" xmlns=\"http://www.ecb.int/vocabulary/2002-08-01/eurofxref\"><Cube><Cube time=\"2017-05-29\"><Cube currency=\"USD\" rate=\"1.1188\"/><Cube currency=\"JPY\" rate=\"124.57\"/></Cube></Cube></gesmes:Envelope>")
      EuropaRates.configuration.store = :file
      allow(EuropaRates::Store).to receive(:rate_document).and_return(@doc)
    end
    it "should return rates" do
      expect(EuropaRates::Store.live_rates).to eq({Date.parse("2017-05-29") => {"USD" => 1.1188, "JPY" => 124.57}})
    end
  end

  describe "rate_document" do
    before(:each) do
      @net_http_double = double("Net::HTTP")
      @http_double = double("http")
      @response = double("response")
      allow(@response).to receive(:body).and_return("</root>")
      expect(@net_http_double).to receive(:start).and_yield(@http_double).and_return(@response)
    end
    it "should call the default url" do
      expect(Net::HTTP).to receive(:new).with("www.ecb.europa.eu", 80).and_return(@net_http_double)
      expect(@http_double).to receive(:get).with(URI.parse("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml"), {})
      EuropaRates::Store.rate_document
    end
    it "should call a custom url" do
      EuropaRates.configuration.url = "http://test-url.local/path"
      expect(Net::HTTP).to receive(:new).with("test-url.local", 80).and_return(@net_http_double)
      expect(@http_double).to receive(:get).with(URI.parse("http://test-url.local/path"), {})
      EuropaRates::Store.rate_document
    end
  end

  describe "update!" do

    before(:each) do
      EuropaRates.configuration.store = :file
      expect(EuropaRates::Store).to receive(:live_rates).and_return({Date.today => {"RATE" => 1.0, "RATE2" => 2.0}, Date.today-1 => {"RATE" => 1.0, "RATE2" => 2.0}})
      @store = EuropaRates::Store.factory
    end

    it "should store supplied rates" do
      expect(@store).to receive(:set_rates_for).exactly(2).times
      @store.update!
    end
  end

end
