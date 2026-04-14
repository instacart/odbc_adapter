require "integration_helper"

RSpec.describe "Selection" do
  it "returns the first record" do
    expect(User.first.first_name).to eq("Kevin")
  end

  it "plucks column values in order" do
    expected = %w[Ash Jason Kevin Michal Ryan Sharif]
    expect(User.order(:first_name).pluck(:first_name)).to eq(expected)
  end

  it "applies limit and offset" do
    expected = %w[Kevin Michal Ryan]
    expect(User.order(:first_name).limit(3).offset(2).pluck(:first_name)).to eq(expected)
  end

  it "finds a record by id" do
    user = User.last
    expect(User.find(user.id)).to eq(user)
  end

  it "filters with arel conditions" do
    expect(User.lots_of_letters.count).to eq(2)
  end

  it "filters with boolean where clause" do
    expect(Todo.where(published: true).count).to eq(4)
  end
end
