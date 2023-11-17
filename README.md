# ODBCAdapter [![License][license-badge]][license-link]

| ActiveRecord | Gem Version | Branch | Status |
|--------------|-------------|--------|--------|
| `5.x`        | `~> '5.0'`  | [`master`][5.x-branch] | [![Build Status][5.x-build-badge]][build-link] |
| `4.x`        | `~> '4.0'`  | [`4.2.x`][4.x-branch]  | [![Build Status][4.x-build-badge]][build-link] |

## Supported Databases

- PostgreSQL 9
- MySQL 5
- Snowflake

You can also register your own adapter to get more support for your DBMS
`ODBCAdapter.register`.

## Installation

Ensure you have the ODBC driver installed on your machine. You will also need
the driver for whichever database to which you want ODBC to connect.

Add this line to your application's Gemfile:

```ruby
gem 'odbc_adapter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install odbc_adapter

## Usage

Configure your `database.yml` by either using the `dsn` option to point to a DSN
that corresponds to a valid entry in your `~/.odbc.ini` file:

```yml
development:
  adapter:  odbc
  dsn: MyDatabaseDSN
```

or by using the `conn_str` option and specifying the entire connection string:

```yml
development:
  adapter: odbc
  conn_str: "DRIVER={PostgreSQL ANSI};SERVER=localhost;PORT=5432;DATABASE=my_database;UID=postgres;"
```

ActiveRecord models that use this connection will now be connecting to the
configured database using the ODBC driver.

### Extending

Configure your own adapter by registering it in your application's bootstrap
process. For example, you could add the following to a Rails application via
`config/initializers/custom_database_adapter.rb`

```ruby
ODBCAdapter.register(/custom/, ActiveRecord::ConnectionAdapters::ODBCAdapter) do
  # Overrides
end
```

```yml
development:
  adapter: odbc
  dsn: CustomDB
```

## Testing

To run the tests, you'll need the ODBC driver as well as the connection adapter for each database against which you're trying to test. Then run `DSN=MyDatabaseDSN bundle exec rake test` and the test suite will be run by connecting to your database.

## Contributing

Bug reports and pull requests are welcome on [GitHub][github-repo].

## Datatype References


Reference https://docs.snowflake.com/en/sql-reference/intro-summary-data-types

https://github.com/rails/rails/blob/main/activerecord/lib/active_record/connection_adapters/abstract_adapter.rb#L877-L908

```
["number",
 "decimal",
 "numeric",
 "int",
 "integer",
 "bigint",
 "smallint",
 "tinyint",
 "byteint",
 "float",
 "float4",
 "float8",
 "double",
 "real",
 "varchar",
 "char",
 "character",
 "string",
 "text",
 "binary",
 "varbinary",
 "boolean",
 "date",
 "datetime",
 "time",
 "timestamp",
 "timestamp_ltz",
 "timestamp_ntz",
 "timestamp_tz",
 "variant",
 "object",
 "array",
 "geography",
 "geometry"]
```


Possible mapping from chatgpt

| Snowflake Data Type   | Ruby ActiveRecord Type | PostgreSQL Type  |
| --------------------- | ---------------------- | ---------------- |
| number                | :decimal               |  numeric
| decimal               | :decimal               |  numeric
| numeric               | :decimal               |  numeric
| int                   | :integer               |  integer
| integer               | :integer               |  integer
| bigint                | :bigint                |  bigint
| smallint              | :integer               |  smallint
| tinyint               | :integer               |  smallint
| byteint               | :integer               |  smallint
| float                 | :float                 |  double precision
| float4                | :float                 |  real
| float8                | :float                 |  double precision
| double                | :float                 |  double precision
| real                  | :float                 |  real
| varchar               | :string                |  character varying
| char                  | :string                |  character
| character             | :string                |  character
| string                | :string                |  character varying
| text                  | :text                  |  text
| binary                | :binary                |  bytea
| varbinary             | :binary                |  bytea
| boolean               | :boolean               |  boolean
| date                  | :date                  |  date
| datetime              | :datetime              |  timestamp without time zone
| time                  | :time                  |  time without time zone
| timestamp             | :timestamp             |  timestamp without time zone
| timestamp_ltz         | :timestamp             |  timestamp without time zone
| timestamp_ntz         | :timestamp             |  timestamp without time zone
| timestamp_tz          | :timestamp             |  timestamp with time zone
| variant               | :jsonb                 |  jsonb
| object                | :jsonb                 |  jsonb
| array                 | :jsonb                 |  jsonb
| geography             | :st_point, :st_polygon,|  geography
|                       | :st_multipolygon       |
| geometry              | :st_point, :st_polygon,|  geometry
|                       | :st_multipolygon       |



## Prior Work

A lot of this work is based on [OpenLink's ActiveRecord adapter][openlink-activerecord-adapter] which works for earlier versions of Rails. 5.0.x compatability work was completed by the [Localytics][localytics-github] team.

[4.x-branch]: https://github.com/localytics/odbc_adapter/tree/v4.2.x
[4.x-build-badge]: https://travis-ci.org/localytics/odbc_adapter.svg?branch=4.2.x
[5.x-branch]: https://github.com/localytics/odbc_adapter/tree/master
[5.x-build-badge]: https://travis-ci.org/localytics/odbc_adapter.svg?branch=master
[build-link]: https://travis-ci.org/localytics/odbc_adapter/branches
[github-repo]: https://github.com/localytics/odbc_adapter
[license-badge]: https://img.shields.io/github/license/localytics/odbc_adapter.svg
[license-link]: https://github.com/localytics/odbc_adapter/blob/master/LICENSE
[localytics-github]: https://github.com/localytics
[openlink-activerecord-adapter]: https://github.com/dosire/activerecord-odbc-adapter
[supported-versions-badge]: https://img.shields.io/badge/active__record-4.x--5.x-green.svg
