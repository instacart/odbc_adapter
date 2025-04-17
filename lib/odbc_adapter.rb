# Requiring with this pattern to mirror ActiveRecord
require "active_record/connection_adapters/odbc_adapter"

if ActiveRecord::ConnectionAdapters.respond_to?(:register)
  ActiveRecord::ConnectionAdapters.register("odbc", "ActiveRecord::ConnectionAdapters::ODBCAdapter", "active_record/connection_adapters/odbc_adapter")
end
