require "integration_helper"

RSpec.describe "Metadata" do
  it "lists data sources" do
    data_sources = %w[ar_internal_metadata todos users]
    data_sources += %w[schema_migrations] if ActiveRecord.version >= "7.1"
    expect(User.connection.data_sources.sort).to eq(data_sources.sort)
  end

  it "lists column names" do
    expected = %w[created_at first_name id last_name letters updated_at]
    expect(User.column_names.sort).to eq(expected)
  end

  it "identifies the primary key" do
    expect(User.connection.primary_key("users")).to eq("id")
  end
end
