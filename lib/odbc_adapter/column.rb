module ODBCAdapter
  class Column < ActiveRecord::ConnectionAdapters::Column
    attr_reader :native_type

    # Add the native_type accessor to allow the native DBMS to report back what
    # it uses to represent the column internally.
    def initialize(*, native_type: nil, **)
      super(*, **)
      @native_type = native_type
    end
  end
end
