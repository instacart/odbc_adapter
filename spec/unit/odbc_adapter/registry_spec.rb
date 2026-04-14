RSpec.describe ODBCAdapter::Registry do
  describe "#adapter_for" do
    it "returns a matching adapter class" do
      registry = described_class.new
      adapter = registry.adapter_for("PostgreSQL")
      expect(adapter).to eq(ODBCAdapter::Adapters::PostgreSQLODBCAdapter)
    end

    it "returns the null adapter for unknown databases" do
      registry = described_class.new
      adapter = registry.adapter_for("Unknown DB")
      expect(adapter).to eq(ODBCAdapter::Adapters::NullODBCAdapter)
    end
  end

  describe "#register" do
    it "registers a custom adapter with a block" do
      registry = described_class.new

      require File.join("odbc_adapter", "adapters", "null_odbc_adapter")
      registry.register(/foobar/, ODBCAdapter::Adapters::NullODBCAdapter) do
        def initialize() end # rubocop:disable Style/RedundantInitialize

        def quoted_true
          "foobar"
        end
      end

      adapter = registry.adapter_for("Foo Bar")
      expect(adapter).to be_a(Class)
      expect(adapter.superclass).to eq(ODBCAdapter::Adapters::NullODBCAdapter)
      expect(adapter.new.quoted_true).to eq("foobar")
    end
  end
end
