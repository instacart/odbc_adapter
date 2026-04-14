require "integration_helper"

RSpec.describe ODBCAdapter::DatabaseMetadata do
  subject(:metadata) do
    ActiveRecord::Base.connection.instance_variable_get(:@database_metadata)
  end

  describe "dynamic field accessors" do
    it "exposes dbms_name as a string" do
      expect(metadata.dbms_name).to be_a(String)
      expect(metadata.dbms_name).to match(/postgres/i)
    end

    it "exposes dbms_ver" do
      expect(metadata.dbms_ver).to be_a(String)
      expect(metadata.dbms_ver).not_to be_empty
    end

    it "exposes identifier_quote_char" do
      expect(metadata.identifier_quote_char).to be_a(String)
    end

    it "exposes max_identifier_len as an integer" do
      expect(metadata.max_identifier_len).to be_a(Integer)
      expect(metadata.max_identifier_len).to be > 0
    end

    it "exposes max_table_name_len as an integer" do
      expect(metadata.max_table_name_len).to be_a(Integer)
      expect(metadata.max_table_name_len).to be >= 0
    end

    it "exposes user_name" do
      expect(metadata.user_name).to be_a(String)
    end

    it "exposes database_name" do
      expect(metadata.database_name.strip).to eq("odbc_test")
    end
  end

  describe "#upcase_identifiers?" do
    it "returns a boolean" do
      expect(metadata.upcase_identifiers?).to be(true).or be(false)
    end
  end

  describe "#adapter_class" do
    it "returns the PostgreSQL adapter class" do
      expect(metadata.adapter_class).to eq(ODBCAdapter::Adapters::PostgreSQLODBCAdapter)
    end
  end

  describe "#values" do
    it "caches all FIELDS from the connection" do
      expect(metadata.values).to be_a(Hash)
      expect(metadata.values.keys).to include(:SQL_DBMS_NAME, :SQL_DBMS_VER)
    end
  end
end
