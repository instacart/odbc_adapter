require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_group "Adapters", "lib/odbc_adapter/adapters"
  add_group "Core", "lib/odbc_adapter"
  add_group "ActiveRecord", "lib/active_record"
  enable_coverage :branch
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "odbc_adapter"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
