require "integration_helper"

RSpec.describe "Connection management" do
  let(:conn) { ActiveRecord::Base.connection }

  after do
    conn.reconnect!
  end

  it "manages connection lifecycle" do
    expect(conn).to be_active

    conn.disconnect!
    expect(conn).not_to be_active

    conn.disconnect!
    expect(conn).not_to be_active

    conn.reconnect!
    expect(conn).to be_active
  end
end
