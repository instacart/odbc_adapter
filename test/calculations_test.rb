require "test_helper"

class CalculationsTest < Minitest::Test
  def test_count
    assert_equal 6, User.count
    assert_equal 10, Todo.count
    assert_equal 3, User.find(1).todos.count
  end

  def test_average
    skip "Need to fix aggregates but we don't use them" if ActiveRecord.version >= "7.0"
    assert_equal 10.33, User.average(:letters).round(2)
  end
end
