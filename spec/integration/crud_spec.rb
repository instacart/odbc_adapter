require "integration_helper"

RSpec.describe "CRUD operations" do
  def with_transaction
    User.transaction do
      yield
      raise ActiveRecord::Rollback
    end
  end

  it "creates a record" do
    with_transaction do
      User.create(first_name: "foo", last_name: "bar")
      expect(User.count).to eq(7)
    end
  end

  it "updates a record" do
    with_transaction do
      user = User.first
      user.letters = 47
      user.save!

      expect(user.reload.letters).to eq(47)
    end
  end

  it "destroys a record" do
    with_transaction do
      User.last.destroy
      expect(User.count).to eq(5)
    end
  end
end
