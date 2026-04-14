RSpec.describe "ODBC connection string parsing" do
  # Test the parsing logic used by odbc_conn_str_connection:
  #   config[:conn_str].split(";").map { |option| option.split("=", 2) }.to_h
  def parse_conn_str(conn_str)
    conn_str.split(";").map { |option| option.split("=", 2) }.to_h
  end

  context "when values contain equals signs" do
    it "preserves equals signs in the value portion" do
      attrs = parse_conn_str("Foo=Bar;Foo2=Something=with=equals")
      expect(attrs).to eq({ "Foo" => "Bar", "Foo2" => "Something=with=equals" })
    end
  end

  context "when values contain no extra equals signs" do
    it "parses key-value pairs correctly" do
      attrs = parse_conn_str("Foo=Bar;Foo2=Something without equals")
      expect(attrs).to eq({ "Foo" => "Bar", "Foo2" => "Something without equals" })
    end
  end

  context "with a realistic PostgreSQL connection string" do
    it "parses DRIVER with curly braces correctly" do
      conn_str = "DRIVER={PostgreSQL ANSI};SERVER=localhost;PORT=5432;DATABASE=test;UID=postgres;"
      attrs = parse_conn_str(conn_str)

      expect(attrs["DRIVER"]).to eq("{PostgreSQL ANSI}")
      expect(attrs["SERVER"]).to eq("localhost")
      expect(attrs["PORT"]).to eq("5432")
      expect(attrs["DATABASE"]).to eq("test")
      expect(attrs["UID"]).to eq("postgres")
    end
  end

  context "with an empty trailing segment" do
    it "handles trailing semicolons" do
      attrs = parse_conn_str("Foo=Bar;")
      expect(attrs).to include("Foo" => "Bar")
    end
  end
end
