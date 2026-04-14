require "integration_helper"

RSpec.describe "Calculations" do
  describe "count" do
    it "counts users" do
      expect(User.count).to eq(6)
    end

    it "counts todos" do
      expect(Todo.count).to eq(10)
    end

    it "counts associated todos" do
      expect(User.find(1).todos.count).to eq(3)
    end
  end

  describe "average" do
    it "calculates the average of a column" do
      skip "Need to fix aggregates but we don't use them" if ActiveRecord.version >= "7.0"
      expect(User.average(:letters).round(2)).to eq(10.33)
    end
  end
end
