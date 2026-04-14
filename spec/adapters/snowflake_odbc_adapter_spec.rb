require "odbc_adapter/adapters/snowflake_odbc_adapter"

RSpec.describe ODBCAdapter::Adapters::SnowflakeODBCAdapter do
  # Use allocate to create an instance without calling initialize,
  # which requires a real ODBC connection.
  let(:adapter) { described_class.allocate }

  describe "#quote_column_name" do
    it "returns the name as a plain string for symbols" do
      expect(adapter.quote_column_name(:foo_bar)).to eq("foo_bar")
    end

    it "returns the name unchanged for mixed-case strings" do
      expect(adapter.quote_column_name("FooBar")).to eq("FooBar")
    end

    it "does not wrap the name in quotes" do
      result = adapter.quote_column_name("column_name")
      expect(result).not_to start_with('"')
      expect(result).not_to end_with('"')
    end
  end

  describe "#prepared_statements" do
    it "returns false" do
      expect(adapter.prepared_statements).to be false
    end
  end
end
