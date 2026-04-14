require "odbc_adapter/database_metadata"

RSpec.describe ODBCAdapter::DatabaseMetadata do
  let(:connection) { double("ODBC::Connection") }

  before do
    # Stub ODBC constants that DatabaseMetadata references
    stub_const("ODBC::SQL_DBMS_NAME", :SQL_DBMS_NAME)
    stub_const("ODBC::SQL_DBMS_VER", :SQL_DBMS_VER)
    stub_const("ODBC::SQL_IDENTIFIER_CASE", :SQL_IDENTIFIER_CASE)
    stub_const("ODBC::SQL_QUOTED_IDENTIFIER_CASE", :SQL_QUOTED_IDENTIFIER_CASE)
    stub_const("ODBC::SQL_IDENTIFIER_QUOTE_CHAR", :SQL_IDENTIFIER_QUOTE_CHAR)
    stub_const("ODBC::SQL_MAX_IDENTIFIER_LEN", :SQL_MAX_IDENTIFIER_LEN)
    stub_const("ODBC::SQL_MAX_TABLE_NAME_LEN", :SQL_MAX_TABLE_NAME_LEN)
    stub_const("ODBC::SQL_USER_NAME", :SQL_USER_NAME)
    stub_const("ODBC::SQL_DATABASE_NAME", :SQL_DATABASE_NAME)
    stub_const("ODBC::SQL_IC_UPPER", 1)

    allow(connection).to receive(:get_info) do |field|
      case field
      when :SQL_DBMS_NAME          then "PostgreSQL"
      when :SQL_DBMS_VER           then "14.0"
      when :SQL_IDENTIFIER_CASE    then 1 # SQL_IC_UPPER
      when :SQL_IDENTIFIER_QUOTE_CHAR then '"'
      when :SQL_MAX_IDENTIFIER_LEN then 128
      when :SQL_MAX_TABLE_NAME_LEN then 64
      when :SQL_USER_NAME          then "test_user"
      when :SQL_DATABASE_NAME      then "test_db"
      else nil
      end
    end
  end

  subject(:metadata) { described_class.new(connection) }

  describe "dynamic field accessors" do
    it "exposes dbms_name" do
      expect(metadata.dbms_name).to eq("PostgreSQL")
    end

    it "exposes dbms_ver" do
      expect(metadata.dbms_ver).to eq("14.0")
    end

    it "exposes identifier_quote_char" do
      expect(metadata.identifier_quote_char).to eq('"')
    end

    it "exposes max_identifier_len" do
      expect(metadata.max_identifier_len).to eq(128)
    end

    it "exposes max_table_name_len" do
      expect(metadata.max_table_name_len).to eq(64)
    end

    it "exposes user_name" do
      expect(metadata.user_name).to eq("test_user")
    end

    it "exposes database_name" do
      expect(metadata.database_name).to eq("test_db")
    end
  end

  describe "#upcase_identifiers?" do
    it "returns true when identifier_case is SQL_IC_UPPER" do
      expect(metadata.upcase_identifiers?).to be true
    end

    it "memoizes the result" do
      metadata.upcase_identifiers?
      metadata.upcase_identifiers?
      # get_info is only called once during initialize, not on each call
      expect(connection).to have_received(:get_info).with(:SQL_IDENTIFIER_CASE).once
    end

    context "when identifier_case is not SQL_IC_UPPER" do
      before do
        allow(connection).to receive(:get_info).with(:SQL_IDENTIFIER_CASE).and_return(0)
      end

      it "returns false" do
        metadata = described_class.new(connection)
        expect(metadata.upcase_identifiers?).to be false
      end
    end
  end

  describe "#adapter_class" do
    it "delegates to ODBCAdapter.adapter_for with the dbms_name" do
      expect(metadata.adapter_class).to eq(ODBCAdapter::Adapters::PostgreSQLODBCAdapter)
    end
  end
end
