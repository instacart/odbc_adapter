require "integration_helper"

RSpec.describe "ODBC connection string (live)" do
  def conn_str_connection(conn_str)
    ActiveRecord::ConnectionAdapters::ODBCAdapter.__send__(:odbc_conn_str_connection, conn_str: conn_str)
  end

  def base_conn_str
    ENV.fetch("CONN_STR").chomp(";")
  end

  before do
    skip "No CONN_STR set" unless ENV.fetch("CONN_STR", nil)
  end

  it "parses key-value pairs and connects" do
    connection, config = conn_str_connection(base_conn_str)

    expect(connection).to be_connected
    expect(config[:driver]).to be_a(ODBC::Driver)
    expect(config[:driver].name).to eq("odbc")
    expect(config[:driver].attrs).to include(
      "DRIVER" => "{PostgreSQL ANSI}",
      "SERVER" => "localhost",
      "PORT" => "5432",
      "DATABASE" => "odbc_test",
      "UID" => "postgres",
    )
  ensure
    connection&.disconnect
  end

  it "handles trailing semicolons" do
    connection, config = conn_str_connection("#{base_conn_str};")

    expect(connection).to be_connected
    expect(config[:driver].attrs).not_to have_key("")
  ensure
    connection&.disconnect
  end

  it "preserves equals signs in values" do
    connection, config = conn_str_connection("#{base_conn_str};CustomKey=val=with=equals")

    expect(connection).to be_connected
    expect(config[:driver].attrs).to include("CustomKey" => "val=with=equals")
  ensure
    connection&.disconnect
  end

  it "preserves curly braces in values" do
    connection, config = conn_str_connection(base_conn_str)

    expect(config[:driver].attrs["DRIVER"]).to eq("{PostgreSQL ANSI}")
  ensure
    connection&.disconnect
  end
end
