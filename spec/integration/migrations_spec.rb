require "integration_helper"

RSpec.describe "Migrations" do
  let(:connection) { User.connection }

  describe "table CRUD" do
    after do
      connection.drop_table(:foos, if_exists: true)
      connection.drop_table(:bars, if_exists: true)
    end

    it "creates, renames, and drops tables" do
      connection.create_table(:foos, force: true) do |t|
        t.timestamps null: false
      end
      expect(connection.columns(:foos).count).to eq(3)

      connection.rename_table(:foos, :bars)
      expect(connection.columns(:bars).count).to eq(3)

      connection.drop_table(:bars)
    end
  end

  describe "column CRUD" do
    it "adds, renames, and removes columns" do
      previous_count = connection.columns(:users).count

      connection.add_column(:users, :foo, :integer)
      expect(connection.columns(:users).count).to eq(previous_count + 1)

      connection.rename_column(:users, :foo, :bar)
      expect(connection.columns(:users).count).to eq(previous_count + 1)

      connection.remove_column(:users, :bar)
      expect(connection.columns(:users).count).to eq(previous_count)
    end
  end
end
