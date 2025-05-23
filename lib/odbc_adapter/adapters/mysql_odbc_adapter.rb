module ODBCAdapter
  module Adapters
    # Overrides specific to MySQL. Mostly taken from
    # ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter
    class MySQLODBCAdapter < ActiveRecord::ConnectionAdapters::ODBCAdapter
      PRIMARY_KEY = "INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY".freeze

      class BindSubstitution < Arel::Visitors::MySQL
        # BindVisitor was removed in Arel 9 aka Rails 5.2
        include Arel::Visitors::BindVisitor if Arel::VERSION.to_i < 9
      end

      def arel_visitor
        BindSubstitution.new(self)
      end

      # Explicitly turning off prepared statements in the MySQL adapter because
      # of a weird bug with SQLDescribeParam returning a string type for LIMIT
      # parameters. This is blocking them from running with an error:
      #
      #     You have an error in your SQL syntax; ...
      #     ... right syntax to use near ''1'' at line 1: ...
      def prepared_statements
        false
      end

      def truncate(table_name, name = nil)
        execute("TRUNCATE TABLE #{quote_table_name(table_name)}", name)
      end

      # Quotes a string, escaping any ' (single quote) and \ (backslash)
      # characters.
      def quote_string(string)
        string.gsub("\\", '\&\&').gsub("'", "''")
      end

      def quoted_true
        "1"
      end

      def unquoted_true
        1
      end

      def quoted_false
        "0"
      end

      def unquoted_false
        0
      end

      def disable_referential_integrity(&_block)
        old = select_value("SELECT @@FOREIGN_KEY_CHECKS")

        begin
          update("SET FOREIGN_KEY_CHECKS = 0")
          yield
        ensure
          update("SET FOREIGN_KEY_CHECKS = #{old}")
        end
      end

      # Create a new MySQL database with optional <tt>:charset</tt> and
      # <tt>:collation</tt>. Charset defaults to utf8.
      #
      # Example:
      #   create_database 'charset_test', charset: 'latin1',
      #                                   collation: 'latin1_bin'
      #   create_database 'rails_development'
      #   create_database 'rails_development', charset: :big5
      def create_database(name, options = {})
        charset = options[:charset] || "utf8"
        if options[:collation]
          execute("CREATE DATABASE `#{name}` DEFAULT CHARACTER SET `#{charset}` COLLATE `#{options[:collation]}`")
        else
          execute("CREATE DATABASE `#{name}` DEFAULT CHARACTER SET `#{charset}`")
        end
      end

      # Drops a MySQL database.
      #
      # Example:
      #   drop_database('rails_development')
      def drop_database(name)
        execute("DROP DATABASE IF EXISTS `#{name}`")
      end

      def create_table(name, options = {})
        super(name, { options: "ENGINE=InnoDB" }.merge(options))
      end

      # Renames a table.
      def rename_table(name, new_name)
        execute("RENAME TABLE #{quote_table_name(name)} TO #{quote_table_name(new_name)}")
      end

      def change_column(table_name, column_name, type, options = {})
        options[:default] = column_for(table_name, column_name).default unless options_include_default?(options)

        column_type = type_to_sql(type, options[:limit], options[:precision], options[:scale])
        change_column_sql = "ALTER TABLE #{table_name} CHANGE #{column_name} #{column_name} #{column_type}"
        add_column_options!(change_column_sql, options)
        execute(change_column_sql)
      end

      def change_column_default(table_name, column_name, default_or_changes)
        default = extract_new_default_value(default_or_changes)
        column = column_for(table_name, column_name)
        change_column(table_name, column_name, column.sql_type, default: default)
      end

      def change_column_null(table_name, column_name, null, default = nil)
        column = column_for(table_name, column_name)

        unless null || default.nil?
          quoted_table_name = quote_table_name(table_name)
          quoted_column_name = quote_column_name(column_name)
          execute <<~SQL
            UPDATE #{quoted_table_name} SET #{quoted_column_name}=#{quote(default)} WHERE #{quoted_column_name} IS NULL
          SQL
        end
        change_column(table_name, column_name, column.sql_type, null: null)
      end

      def rename_column(table_name, column_name, new_column_name)
        column = column_for(table_name, column_name)
        current_type = column.native_type
        current_type << "(#{column.limit})" if column.limit
        execute("ALTER TABLE #{table_name} CHANGE #{column_name} #{new_column_name} #{current_type}")
      end

      # Skip primary key indexes
      def indexes(table_name, name = nil)
        super.reject { |i| i.unique && i.name =~ /^PRIMARY$/ }
      end

      # MySQL 5.x doesn't allow DEFAULT NULL for first timestamp column in a
      # table
      def options_include_default?(opts)
        if opts.key?(:default) && opts[:default].nil? && opts.key?(:column) && opts[:column].native_type =~ /timestamp/i
          opts.delete(:default)
        end

        super
      end

      protected

      def insert_sql(sql, name = nil, pri_key = nil, id_value = nil, sequence_name = nil)
        super
        id_value || last_inserted_id(nil)
      end

      def last_inserted_id(_result)
        select_value("SELECT LAST_INSERT_ID()").to_i
      end
    end
  end
end
