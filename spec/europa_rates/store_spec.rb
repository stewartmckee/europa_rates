require "spec_helper"

RSpec.describe EuropaRates::Store do

  it "should initialize a new object"
  it "should default options to empty hash"
  it "should set @options to passed in object"

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

end
