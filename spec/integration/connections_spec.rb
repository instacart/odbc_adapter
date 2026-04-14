require "integration_helper"

class ConnectionsTestDummyActiveRecordModel < ActiveRecord::Base
  self.abstract_class = true
end

RSpec.describe "Connections" do
  let(:options) do
    opts = { adapter: "odbc" }
    opts[:conn_str] = ENV["CONN_STR"] if ENV["CONN_STR"]
    opts[:dsn]      = ENV["DSN"] if ENV["DSN"]
    opts[:dsn]      = "ODBCAdapterPostgreSQLTest" if opts.values_at(:conn_str, :dsn).compact.empty?
    opts
  end

  let(:connection) do
    ConnectionsTestDummyActiveRecordModel.establish_connection(options)
    ConnectionsTestDummyActiveRecordModel.connection
  end

  after do
    connection.disconnect!
  end

  it "reports active? matching raw connection state" do
    expect(connection.active?).to eq(connection.raw_connection.connected?)
  end

  it "disconnects the raw connection" do
    raw_connection = connection.raw_connection
    expect(raw_connection.connected?).to be true

    connection.disconnect!
    expect(raw_connection.connected?).to be false
  end

  it "reconnects with a new raw connection" do
    old_raw_connection = connection.raw_connection
    expect(connection).to be_active

    connection.reconnect!
    expect(connection.raw_connection).not_to eq(old_raw_connection)
    expect(connection).to be_active
  end
end
