module ODBCAdapter
  module Quoting
    extend ActiveSupport::Concern
    module ClassMethods
      # Returns a quoted form of the column name.
      # Called by Rails at the class level with 1 arg (e.g. SchemaCreation)
      # and by instances with 2 args (passing database_metadata for ODBC quoting).
      def quote_column_name(name, database_metadata = nil)
        name = name.to_s
        return name unless database_metadata

        quote_char = database_metadata.identifier_quote_char.to_s.strip

        return name if quote_char.empty?

        quote_char = quote_char[0]

        # Avoid quoting any already quoted name
        return name if name[0] == quote_char && name[-1] == quote_char

        # If upcase identifiers, only quote mixed case names.
        return name if database_metadata.upcase_identifiers? && name !~ /([A-Z]+[a-z])|([a-z]+[A-Z])/

        "#{quote_char.chr}#{name}#{quote_char.chr}"
      end
    end

    def quote_column_name(column_name)
      self.class.quote_column_name(column_name, database_metadata)
    end

    # Uses instance-level quote_column_name so subclass overrides
    # (e.g. Snowflake's unquoted identifiers) are respected.
    def quote_table_name(table_name)
      table_name.to_s.split(".").map { |part| quote_column_name(part) }.join(".")
    end

    # Quotes a string, escaping any ' (single quote) characters.
    def quote_string(string)
      string.gsub("'", "''")
    end

    # Ideally, we'd return an ODBC date or timestamp literal escape
    # sequence, but not all ODBC drivers support them.
    def quoted_date(value)
      if value.acts_like?(:time)
        default_tz = ActiveRecord.try(:default_timezone) || ActiveRecord::Base.default_timezone
        zone_conversion_method = default_tz == :utc ? :getutc : :getlocal

        value = value.send(zone_conversion_method) if value.respond_to?(zone_conversion_method)
        value.strftime("%Y-%m-%d %H:%M:%S") # Time, DateTime
      else
        value.strftime("%Y-%m-%d") # Date
      end
    end
  end
end
