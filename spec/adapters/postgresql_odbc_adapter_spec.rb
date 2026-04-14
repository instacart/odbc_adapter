require "integration_helper"

RSpec.describe ODBCAdapter::Adapters::PostgreSQLODBCAdapter do
  let(:connection) { ActiveRecord::Base.connection }

  describe "#quote_string" do
    it "escapes single quotes" do
      expect(connection.quote_string("it's")).to eq("it''s")
    end

    it "escapes backslashes" do
      expect(connection.quote_string('foo\bar')).to eq('foo\\\\bar')
    end

    it "escapes both backslashes and single quotes" do
      expect(connection.quote_string("it's a \\path")).to eq("it''s a \\\\path")
    end

    it "returns empty string unchanged" do
      expect(connection.quote_string("")).to eq("")
    end
  end

  describe "#prepared_statements" do
    it "returns false" do
      expect(connection.prepared_statements).to be false
    end
  end

  describe "#table_filtered?" do
    it "filters information_schema tables" do
      expect(connection.table_filtered?("information_schema", "TABLE")).to be true
    end

    it "filters pg_catalog tables" do
      expect(connection.table_filtered?("pg_catalog", "TABLE")).to be true
    end

    it "filters non-TABLE types" do
      expect(connection.table_filtered?("public", "VIEW")).to be true
    end

    it "does not filter regular tables" do
      expect(connection.table_filtered?("public", "TABLE")).to be false
    end
  end

  describe "#native_database_types" do
    it "includes boolean type mapped to bool" do
      expect(connection.native_database_types[:boolean]).to eq({ name: "bool" })
    end

    it "includes standard Rails types" do
      types = connection.native_database_types
      expect(types).to include(:string, :integer, :boolean)
    end
  end

  describe "#quote_column_name" do
    it "quotes a column name" do
      result = connection.quote_column_name("users")
      expect(result).to be_a(String)
      expect(result).not_to be_empty
    end
  end

  describe "#adapter_name" do
    it "returns ODBC" do
      expect(connection.adapter_name).to eq("ODBC")
    end
  end

  describe "#supports_migrations?" do
    it "returns true" do
      expect(connection.supports_migrations?).to be true
    end
  end

  describe "#current_database" do
    it "returns the database name" do
      expect(connection.current_database).to eq("odbc_test")
    end
  end

  describe "#default_sequence_name" do
    it "returns the sequence name for a table" do
      expect(connection.default_sequence_name("users", "id")).to eq("users_id_seq")
    end
  end

  describe "#distinct" do
    it "returns DISTINCT columns when no orders given" do
      expect(connection.distinct("posts.id", [])).to eq("DISTINCT posts.id")
    end

    it "includes order columns as aliases when orders given" do
      result = connection.distinct("posts.id", ["posts.created_at desc"])
      expect(result).to include("DISTINCT posts.id")
      expect(result).to include("alias_0")
    end
  end
end
