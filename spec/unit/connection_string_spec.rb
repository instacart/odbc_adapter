RSpec.describe "ODBC connection string parsing" do
  let(:driver) { double("ODBC::Driver") }
  let(:database) { double("ODBC::Database") }
  let(:connection) { double("ODBC::Connection") }

  before do
    allow(driver).to receive(:name=)
    allow(driver).to receive(:attrs=)
    allow(ODBC::Driver).to receive(:new).and_return(driver)
    allow(ODBC::Database).to receive(:new).and_return(database)
    allow(database).to receive(:drvconnect).with(driver).and_return(connection)
  end

  def connect(conn_str)
    ActiveRecord::Base.__send__(:odbc_conn_str_connection, conn_str: conn_str)
  end

  context "when values contain equals signs" do
    it "preserves equals signs in the value portion" do
      connect("Foo=Bar;Foo2=Something=with=equals")
      expect(driver).to have_received(:attrs=).with("Foo" => "Bar", "Foo2" => "Something=with=equals")
    end
  end

  context "when values contain no extra equals signs" do
    it "parses key-value pairs correctly" do
      connect("Foo=Bar;Foo2=Something without equals")
      expect(driver).to have_received(:attrs=).with("Foo" => "Bar", "Foo2" => "Something without equals")
    end
  end

  context "with a realistic PostgreSQL connection string" do
    it "parses DRIVER with curly braces correctly" do
      connect("DRIVER={PostgreSQL ANSI};SERVER=localhost;PORT=5432;DATABASE=test;UID=postgres;")
      expect(driver).to have_received(:attrs=).with(
        "DRIVER" => "{PostgreSQL ANSI}",
        "SERVER" => "localhost",
        "PORT" => "5432",
        "DATABASE" => "test",
        "UID" => "postgres",
      )
    end
  end

  context "with a trailing semicolon" do
    it "ignores the empty trailing segment" do
      connect("Foo=Bar;")
      expect(driver).to have_received(:attrs=).with("Foo" => "Bar")
    end
  end
end
