require "integration_helper"

RSpec.describe "ODBC connection string (live)" do
  it "establishes a working connection via CONN_STR" do
    skip "No CONN_STR set" unless ENV.fetch("CONN_STR", nil)

    connection = ActiveRecord::Base.connection
    expect(connection).to be_active
    expect(connection.raw_connection).to be_connected
  end
end
