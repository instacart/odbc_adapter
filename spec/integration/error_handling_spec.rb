require "integration_helper"

RSpec.describe "Error handling" do
  let(:connection) { ActiveRecord::Base.connection }

  describe "duplicate key violation" do
    it "raises ActiveRecord::RecordNotUnique" do
      skip "Exception translation broken on AR >= 7.1" if ActiveRecord.version >= "7.1"

      user = User.first

      expect do
        connection.execute(
          "INSERT INTO users (id, first_name, last_name, letters, created_at, updated_at) " \
          "VALUES (#{user.id}, 'dup', 'test', 1, NOW(), NOW())",
        )
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
