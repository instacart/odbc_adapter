require "integration_helper"

RSpec.describe "ODBC connection string (live)" do
  it "establishes a working connection via CONN_STR" do
    skip "No CONN_STR set" unless ENV["CONN_STR"]

    model = Class.new(ActiveRecord::Base) { self.abstract_class = true }
    model.establish_connection(adapter: "odbc", conn_str: ENV["CONN_STR"])

    connection = model.connection
    expect(connection).to be_active
    expect(connection.raw_connection).to be_connected

    connection.disconnect!
  end
end
