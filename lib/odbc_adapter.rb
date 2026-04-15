# Requiring with this pattern to mirror ActiveRecord
require "active_record/connection_adapters/odbc_adapter"

if ActiveRecord::ConnectionAdapters.respond_to?(:register)
  # Rails 7.2+
  ActiveRecord::ConnectionAdapters.register(
    "odbc",
    "ActiveRecord::ConnectionAdapters::ODBCAdapter",
    "active_record/connection_adapters/odbc_adapter",
  )
else
  # Rails 7.1: adapter resolved via Base.odbc_connection(config)
  ActiveRecord::Base.class_eval do
    def self.odbc_connection(config)
      ActiveRecord::ConnectionAdapters::ODBCAdapter.new(config)
    end
  end
end
