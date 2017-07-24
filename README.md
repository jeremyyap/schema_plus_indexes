[![Gem Version](https://badge.fury.io/rb/schema_plus_indexes.svg)](http://badge.fury.io/rb/schema_plus_indexes)
[![Build Status](https://secure.travis-ci.org/SchemaPlus/schema_plus_indexes.svg)](http://travis-ci.org/SchemaPlus/schema_plus_indexes)
[![Coverage Status](https://img.shields.io/coveralls/SchemaPlus/schema_plus_indexes.svg)](https://coveralls.io/r/SchemaPlus/schema_plus_indexes)

# SchemaPlus::Indexes

SchemaPlus::Indexes adds various convenient capabilities to `ActiveRecord`'s index handling.

SchemaPlus::Indexes is part of the [SchemaPlus](https://github.com/SchemaPlus/) family of Ruby on Rails extension gems.

## Installation

<!-- SCHEMA_DEV: TEMPLATE INSTALLATION - begin -->
<!-- These lines are auto-inserted from a schema_dev template -->
As usual:

```ruby
gem "schema_plus_indexes"                # in a Gemfile
gem.add_dependency "schema_plus_indexes" # in a .gemspec
```

<!-- SCHEMA_DEV: TEMPLATE INSTALLATION - end -->


## Features

### Migrations:

#### Shorthand to define a column with an index:

```ruby
t.string :role,             index: true     # shorthand for index: {}
```

#### Shorthand to define a column with a unique index:
```ruby
t.string :product_code,     index: :unique  # shorthand for index: { unique: true }
```

#### Create multi-column indexes as part of column definition

Adds an option to include other columns in the index:

```ruby
t.string :first_name
t.string :last_name,        index: { with: :first_name }

t.string :country_code
t.string :area_code
t.string :local_number,     index: { with: [:country_code, :area_code] }
```

#### Create indexes with `add_column`, `change_table`

ActiveRecord supports the `index:` option to column definitions when creating table.  SchemaPlus::Indexes extends that to work also with `add_column` and in `change_table`

```ruby
add_column "tablename", "columnname", index: { ... }

change_table :tablename do |t|
  t.integer :column,    index: true
end
```

These of course accept the shorthands and `with:` option described above.

#### Remove index :if_exists

```ruby
remove_index "tablename", "columnname", if_exists: true
```

### Models

SchemaPlus::Indexes lets you easily get the indexes of a model:

```ruby
Model.indexes  # shorthand for `connection.indexes(Model.table_name)`
```

The value gets cached until the next time `Model.reset_column_information` is called.

### Other things...

* Provides consistent behavior regarding attempted duplicate index
  creation: Ignore and log a warning.  Different versions of Rails with
  different db adapters otherwise behave inconsistently: some ignore the
  attempt, some raise an error.

* In the schema dump `schema.rb`, index definitions are included within the
  `create_table` statements rather than added afterwards

* When using SQLite3, makes sure that the definitions returned by
  `connection.indexes` properly include the column orders (`:asc` or `:desc`)

* For the `ActiveRecord::ConnectionAdapters::IndexDefinition` class (the object that's returned by `connection.indexes`), SchemaPlus::Indexes:
  * Provides an `==` operator to compare if two objects refer to an equivalent index
  * Allows calling `new` with a signature that matches add_index: `IndexDefinition.new(table_name, column_names, options)`
  * Fleshes out the `:orders` attribute, listing `:asc` for a column instead of leaving it undefined.
  * Prevents errors from a down :change migration attempting to remove an index that wasn't previously added (this can arise, e.g. with auto-indexing plugins).

## Compatibility

schema_plus_indexes is tested on

<!-- SCHEMA_DEV: MATRIX - begin -->
<!-- These lines are auto-generated by schema_dev based on schema_dev.yml -->
* ruby **2.3.1** with activerecord **4.2**, using **mysql2**, **sqlite3** or **postgresql**
* ruby **2.3.1** with activerecord **5.0**, using **mysql2**, **sqlite3** or **postgresql**
* ruby **2.3.1** with activerecord **5.1**, using **mysql2**, **sqlite3** or **postgresql**

<!-- SCHEMA_DEV: MATRIX - end -->

## History

### v0.2.4

* Supports AR 5.0.  Thanks to [@myabc](https://github.com/myabc)


### v0.2.3

* Missing require

### v0.2.2

* Explicit gem dependencies

### v0.2.1

* Upgrade to schema_plus_core 1.0 and conform

### v0.2.0

* Prevent down :change migrations from failing due to trying to remove non-existent indexes

### v0.1.0

* Initial release, extracted from schema_plus 1.x

## Development & Testing

Are you interested in contributing to schema_plus_indexes?  Thanks!  Please follow
the standard protocol: fork, feature branch, develop, push, and issue pull request.

Some things to know about to help you develop and test:

<!-- SCHEMA_DEV: TEMPLATE USES SCHEMA_DEV - begin -->
<!-- These lines are auto-inserted from a schema_dev template -->
* **schema_dev**:  SchemaPlus::Indexes uses [schema_dev](https://github.com/SchemaPlus/schema_dev) to
  facilitate running rspec tests on the matrix of ruby, activerecord, and database
  versions that the gem supports, both locally and on
  [travis-ci](http://travis-ci.org/SchemaPlus/schema_plus_indexes)

  To to run rspec locally on the full matrix, do:

        $ schema_dev bundle install
        $ schema_dev rspec

  You can also run on just one configuration at a time;  For info, see `schema_dev --help` or the [schema_dev](https://github.com/SchemaPlus/schema_dev) README.

  The matrix of configurations is specified in `schema_dev.yml` in
  the project root.


<!-- SCHEMA_DEV: TEMPLATE USES SCHEMA_DEV - end -->
<!-- SCHEMA_DEV: TEMPLATE USES SCHEMA_PLUS_CORE - begin -->
<!-- These lines are auto-inserted from a schema_dev template -->
* **schema_plus_core**: SchemaPlus::Indexes uses the SchemaPlus::Core API that
  provides middleware callback stacks to make it easy to extend
  ActiveRecord's behavior.  If that API is missing something you need for
  your contribution, please head over to
  [schema_plus_core](https://github.com/SchemaPlus/schema_plus_core) and open
  an issue or pull request.

<!-- SCHEMA_DEV: TEMPLATE USES SCHEMA_PLUS_CORE - end -->
<!-- SCHEMA_DEV: TEMPLATE USES SCHEMA_MONKEY - begin -->
<!-- These lines are auto-inserted from a schema_dev template -->
* **schema_monkey**: SchemaPlus::Indexes is implemented as a
  [schema_monkey](https://github.com/SchemaPlus/schema_monkey) client,
  using [schema_monkey](https://github.com/SchemaPlus/schema_monkey)'s
  convention-based protocols for extending ActiveRecord and using middleware stacks.

<!-- SCHEMA_DEV: TEMPLATE USES SCHEMA_MONKEY - end -->
