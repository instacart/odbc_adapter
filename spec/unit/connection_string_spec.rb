RSpec.describe "ODBC connection string parsing" do
  let(:driver) { double("ODBC::Driver") }
  let(:database) { double("ODBC::Database") }
  let(:connection) { double("ODBC::Connection") }

  before do
    allow(ODBC::Driver).to receive(:new).and_return(driver)
    allow(ODBC::Database).to receive(:new).and_return(database)
    allow(driver).to receive(:name=)
    allow(driver).to receive(:attrs=)
    allow(database).to receive(:drvconnect).with(driver).and_return(connection)
  end

  context "when connection string has equals signs in values" do
    it "parses the connection string correctly" do
      conn_str = "Foo=Bar;Foo2=Something=with=equals"

      ActiveRecord::Base.__send__(:odbc_conn_str_connection, conn_str: conn_str)

      expect(driver).to have_received(:name=).with("odbc")
      expect(driver).to have_received(:attrs=).with({ "Foo" => "Bar", "Foo2" => "Something=with=equals" })
      expect(database).to have_received(:drvconnect).with(driver)
    end
  end

  context "when connection string has no extra equals signs" do
    it "parses the connection string correctly" do
      conn_str = "Foo=Bar;Foo2=Something without equals"

      ActiveRecord::Base.__send__(:odbc_conn_str_connection, conn_str: conn_str)

      expect(driver).to have_received(:name=).with("odbc")
      expect(driver).to have_received(:attrs=).with({ "Foo" => "Bar", "Foo2" => "Something without equals" })
      expect(database).to have_received(:drvconnect).with(driver)
    end
  end
end
