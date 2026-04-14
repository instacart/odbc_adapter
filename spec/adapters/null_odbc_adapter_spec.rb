require "odbc_adapter/adapters/null_odbc_adapter"

RSpec.describe ODBCAdapter::Adapters::NullODBCAdapter do
  let(:adapter) { described_class.allocate }

  describe "#prepared_statements" do
    it "returns false" do
      expect(adapter.prepared_statements).to be false
    end
  end

  describe "#supports_migrations?" do
    it "returns false" do
      expect(adapter.supports_migrations?).to be false
    end
  end

  describe "#arel_visitor" do
    it "returns a BindSubstitution visitor" do
      expect(adapter.arel_visitor).to be_a(described_class::BindSubstitution)
    end
  end
end
