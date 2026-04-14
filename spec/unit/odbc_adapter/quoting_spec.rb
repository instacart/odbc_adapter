require "odbc_adapter/quoting"

RSpec.describe ODBCAdapter::Quoting do
  let(:metadata) { instance_double(ODBCAdapter::DatabaseMetadata) }

  let(:adapter_class) do
    Class.new do
      include ODBCAdapter::Quoting

      attr_reader :database_metadata

      def initialize(metadata)
        @database_metadata = metadata
      end
    end
  end

  let(:adapter) { adapter_class.new(metadata) }

  describe "#quote_string" do
    it "escapes single quotes" do
      expect(adapter.quote_string("it's")).to eq("it''s")
    end

    it "returns empty string unchanged" do
      expect(adapter.quote_string("")).to eq("")
    end

    it "escapes multiple single quotes" do
      expect(adapter.quote_string("it''s a 'test'")).to eq("it''''s a ''test''")
    end
  end

  describe "#quote_column_name" do
    context "when identifier_quote_char is a double quote" do
      before do
        allow(metadata).to receive(:identifier_quote_char).and_return('"')
        allow(metadata).to receive(:upcase_identifiers?).and_return(false)
      end

      it "wraps the column name in quote characters" do
        expect(adapter.quote_column_name(:foo)).to eq('"foo"')
      end

      it "does not double-quote already quoted names" do
        expect(adapter.quote_column_name('"foo"')).to eq('"foo"')
      end
    end

    context "when identifier_quote_char is empty" do
      before do
        allow(metadata).to receive(:identifier_quote_char).and_return("")
      end

      it "returns the name unquoted" do
        expect(adapter.quote_column_name(:foo)).to eq("foo")
      end
    end

    context "when identifier_quote_char is whitespace" do
      before do
        allow(metadata).to receive(:identifier_quote_char).and_return(" ")
      end

      it "returns the name unquoted" do
        expect(adapter.quote_column_name(:foo)).to eq("foo")
      end
    end

    context "when upcase_identifiers? is true" do
      before do
        allow(metadata).to receive(:identifier_quote_char).and_return('"')
        allow(metadata).to receive(:upcase_identifiers?).and_return(true)
      end

      it "does not quote all-lowercase names" do
        expect(adapter.quote_column_name(:foo)).to eq("foo")
      end

      it "does not quote all-uppercase names" do
        expect(adapter.quote_column_name(:FOO)).to eq("FOO")
      end

      it "quotes mixed-case names" do
        expect(adapter.quote_column_name(:FooBar)).to eq('"FooBar"')
      end
    end
  end

  describe "#quoted_date" do
    context "with a Time value" do
      it "formats as datetime string in UTC when default_timezone is :utc" do
        allow(ActiveRecord).to receive(:default_timezone).and_return(:utc)
        time = Time.utc(2024, 6, 15, 12, 30, 45)
        expect(adapter.quoted_date(time)).to eq("2024-06-15 12:30:45")
      end

      it "formats as datetime string in local time when default_timezone is :local" do
        allow(ActiveRecord).to receive(:default_timezone).and_return(:local)
        time = Time.local(2024, 6, 15, 12, 30, 45)
        expect(adapter.quoted_date(time)).to eq("2024-06-15 12:30:45")
      end
    end

    context "with a Date value" do
      it "formats as date-only string" do
        date = Date.new(2024, 6, 15)
        expect(adapter.quoted_date(date)).to eq("2024-06-15")
      end
    end
  end
end
