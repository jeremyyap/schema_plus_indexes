module SchemaPlusIndexes
  module Middleware
    module Migration

      def self.insert
        SchemaMonkey::Middleware::Migration::Column.prepend Shortcuts
        SchemaMonkey::Middleware::Migration::Column.append IndexOnAddColumn
        SchemaMonkey::Middleware::Migration::Index.prepend NormalizeArgs
        SchemaMonkey::Middleware::Migration::Index.prepend IgnoreDuplicates
      end

      class Shortcuts < SchemaMonkey::Middleware::Base
        def call(env)
          case env.options[:index]
          when true then env.options[:index] = {}
          when :unique then env.options[:index] = { :unique => true }
          end
          continue env
        end
      end

      class IndexOnAddColumn < SchemaMonkey::Middleware::Base
        def call(env)
          continue env
          return unless env.options[:index]

          case env.operation
          when :add, :record
            env.caller.add_index(env.table_name, env.column_name, env.options[:index])
          end
        end
      end

      class NormalizeArgs < SchemaMonkey::Middleware::Base
        def call(env)
          {:conditions => :where, :kind => :using}.each do |deprecated, proper|
            if env.options[deprecated]
              ActiveSupport::Deprecation.warn "ActiveRecord index option #{deprecated.inspect} is deprecated, use #{proper.inspect} instead"
              env.options[proper] = env.options.delete(deprecated)
            end
          end
          [:length, :order].each do |key|
            env.options[key].stringify_keys! if env.options[key].is_a? Hash
          end
          env.column_names = Array.wrap(env.column_names).map(&:to_s) + Array.wrap(env.options.delete(:with)).map(&:to_s)
          continue env
        end
      end

      class IgnoreDuplicates < SchemaMonkey::Middleware::Base
        # SchemaPlusIndexes modifies SchemaStatements::add_index so that it ignores
        # errors raised about add an index that already exists -- i.e. that has
        # the same index name, same columns, and same options -- and writes a
        # warning to the log. Some combinations of rails & DB adapter versions
        # would log such a warning, others would raise an error; with
        # SchemaPlusIndexes all versions log the warning and do not raise the error.
        def call(env)
          continue env
        rescue => e
          raise unless e.message.match(/["']([^"']+)["'].*already exists/)
          name = $1
          existing = env.caller.indexes(env.table_name).find{|i| i.name == name}
          attempted = ::ActiveRecord::ConnectionAdapters::IndexDefinition.new(env.table_name, env.column_names, env.options.merge(:name => name))
          raise if attempted != existing
          ::ActiveRecord::Base.logger.warn "[schema_plus_indexes] Index name #{name.inspect}' on table #{env.table_name.inspect} already exists. Skipping."
        end
      end

    end
  end
end