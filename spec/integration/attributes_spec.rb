require "integration_helper"

RSpec.describe "Attributes" do
  it "returns booleans correctly" do
    expect(Todo.first.published?).to be true
    expect(Todo.last.published?).to be false
  end

  it "returns integers correctly" do
    expect(User.first.letters).to be_a(Integer)
  end

  it "returns strings correctly" do
    expect(User.first.first_name).to be_a(String)
    expect(Todo.first.body).to be_a(String)
  end

  it "returns attributes as a Hash" do
    expect(User.first.attributes).to be_a(Hash)
    expect(Todo.first.attributes).to be_a(Hash)
  end
end
