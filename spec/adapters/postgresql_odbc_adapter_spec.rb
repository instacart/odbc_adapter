require "odbc_adapter/adapters/postgresql_odbc_adapter"

RSpec.describe ODBCAdapter::Adapters::PostgreSQLODBCAdapter do
  let(:adapter) { described_class.allocate }

  describe "#quote_string" do
    it "escapes single quotes" do
      expect(adapter.quote_string("it's")).to eq("it''s")
    end

    it "escapes backslashes" do
      expect(adapter.quote_string('foo\bar')).to eq('foo\\\\bar')
    end

    it "escapes both backslashes and single quotes" do
      expect(adapter.quote_string("it's a \\path")).to eq("it''s a \\\\path")
    end

    it "returns empty string unchanged" do
      expect(adapter.quote_string("")).to eq("")
    end
  end

  describe "#prepared_statements" do
    it "returns false" do
      expect(adapter.prepared_statements).to be false
    end
  end

  describe "#table_filtered?" do
    it "filters information_schema tables" do
      expect(adapter.table_filtered?("information_schema", "TABLE")).to be true
    end

    it "filters pg_catalog tables" do
      expect(adapter.table_filtered?("pg_catalog", "TABLE")).to be true
    end

    it "filters non-TABLE types" do
      expect(adapter.table_filtered?("public", "VIEW")).to be true
    end

    it "does not filter regular tables" do
      expect(adapter.table_filtered?("public", "TABLE")).to be false
    end

    it "does not filter SYSTEM TABLE types" do
      expect(adapter.table_filtered?("public", "SYSTEM TABLE")).to be false
    end
  end

  describe "#native_database_types" do
    it "includes boolean type mapped to bool" do
      # Need to stub the super call which requires database_metadata
      metadata = instance_double(ODBCAdapter::DatabaseMetadata)
      adapter.instance_variable_set(:@database_metadata, metadata)

      # Stub column_metadata to return empty types (super's behavior)
      col_metadata = instance_double(ODBCAdapter::ColumnMetadata, native_database_types: {})
      adapter.instance_variable_set(:@column_metadata, col_metadata)

      types = adapter.native_database_types
      expect(types[:boolean]).to eq({ name: "bool" })
    end
  end
end
