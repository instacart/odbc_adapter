require "odbc_adapter/database_limits"

RSpec.describe ODBCAdapter::DatabaseLimits do
  let(:metadata) { instance_double(ODBCAdapter::DatabaseMetadata) }

  let(:adapter) do
    meta = metadata
    Class.new do
      include ODBCAdapter::DatabaseLimits

      define_method(:database_metadata) { meta }
    end.new
  end

  describe "#table_alias_length" do
    it "returns the max of identifier_len and table_name_len" do
      allow(metadata).to receive(:max_identifier_len).and_return(128)
      allow(metadata).to receive(:max_table_name_len).and_return(64)

      expect(adapter.table_alias_length).to eq(128)
    end

    it "returns table_name_len when it is larger" do
      allow(metadata).to receive(:max_identifier_len).and_return(32)
      allow(metadata).to receive(:max_table_name_len).and_return(256)

      expect(adapter.table_alias_length).to eq(256)
    end

    it "returns either value when they are equal" do
      allow(metadata).to receive(:max_identifier_len).and_return(64)
      allow(metadata).to receive(:max_table_name_len).and_return(64)

      expect(adapter.table_alias_length).to eq(64)
    end
  end
end
