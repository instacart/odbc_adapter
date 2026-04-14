require "integration_helper"

RSpec.describe "Schema statements" do
  let(:connection) { ActiveRecord::Base.connection }

  describe "#indexes" do
    after do
      connection.execute('DROP INDEX IF EXISTS "index_users_on_first_name"')
    end

    it "returns indexes for a table" do
      connection.add_index(:users, :first_name, name: "index_users_on_first_name")
      indexes = connection.indexes("users")

      index = indexes.find { |i| i.name == "index_users_on_first_name" }
      expect(index).not_to be_nil
      expect(index.columns).to include("first_name")
      expect(index.unique).to be false
    end

    it "reports unique indexes" do
      connection.add_index(:users, :first_name, name: "index_users_on_first_name", unique: true)
      indexes = connection.indexes("users")

      index = indexes.find { |i| i.name == "index_users_on_first_name" }
      expect(index.unique).to be true
    end
  end

  describe "#views" do
    it "returns an array" do
      expect(connection.views).to be_an(Array)
    end
  end

  describe "#columns" do
    it "returns Column objects with native types" do
      columns = connection.columns("users")
      expect(columns).to all(be_a(ODBCAdapter::Column))

      id_column = columns.find { |c| c.name == "id" }
      expect(id_column.native_type).not_to be_nil
    end
  end

  describe "#truncate" do
    before do
      connection.create_table(:truncate_test, force: true) { |t| t.string :name }
      connection.execute("INSERT INTO truncate_test (name) VALUES ('row1')")
      connection.execute("INSERT INTO truncate_test (name) VALUES ('row2')")
    end

    after do
      connection.drop_table(:truncate_test, if_exists: true)
    end

    it "removes all rows from a table" do
      result = connection.exec_query("SELECT COUNT(*) FROM truncate_test")
      expect(result.rows.first.first).to eq(2)

      connection.truncate("truncate_test")

      result = connection.exec_query("SELECT COUNT(*) FROM truncate_test")
      expect(result.rows.first.first).to eq(0)
    end
  end
end
