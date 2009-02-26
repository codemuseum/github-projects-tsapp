require 'rails_generator'
require 'rails_generator/commands'

module ThriveSmart #:nodoc:
  module Generator #:nodoc:
    module Commands #:nodoc:
      module Create

        def route_custom_resource(resource, parameter_string)
          resource_list = "#{resource.to_sym.inspect}, #{parameter_string}"
          sentinel = 'ActionController::Routing::Routes.draw do |map|'

          logger.route "map.resources #{resource_list}"
          unless options[:pretend]
            gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
              "#{match}\n  map.resources #{resource_list}\n"
            end
          end
        end
        
        def env_asset_host(env, host)
          sentinel = case env
            when 'production'; '"http://assets.example.com"'
            when 'development'; 'raise_delivery_errors = false'
            end

          logger.asset_host  "map.config.action_controller.asset_host = #{host} [#{env}]"
          unless options[:pretend]
            gsub_file "config/environments/#{env}.rb", /(#{Regexp.escape(sentinel)})/mi do |match|
              "#{match}\nconfig.action_controller.asset_host                  = \"#{host}\"\n"
            end
          end
        end
        
        def model_meta_programming(model_underscored, model_path, command)
          model_file = File.join('app/models', model_path, model_underscored + '.rb')
          sentinel = '< ActiveRecord::Base'
          
          logger.model_update "#{command} [#{model_underscored + '.rb'}]"
          unless options[:pretend]
            gsub_file model_file, /(#{Regexp.escape(sentinel)})/mi do |match|
              "#{match}\n  #{command}\n"
            end
          end
        end
        
        def migration_indexing(model_plural_underscored, command)
          migration_directory('db/migrate')
          migration_files = existing_migrations("create_#{model_plural_underscored}")
          
          sentinel = "t.timestamps\n    end"
          migration_files.each do |file_path|
            migration_file = file_path
            logger.migration_update "#{command} [#{file_path}]"
            unless options[:pretend]
              gsub_file migration_file, /(#{Regexp.escape(sentinel)})/mi do |match|
                "#{match}\n    #{command}"
              end
            end
          end
        end
        
      end

      module Destroy

        def route_custom_resource(resource, parameter_string)
          resource_list = "#{resource.to_sym.inspect}, #{parameter_string}"
          look_for = "\n  map.resources #{resource_list}\n"
          logger.route "map.resources #{resource_list}"
          gsub_file 'config/routes.rb', /(#{Regexp.escape(look_for)})/mi, ''
        end
        
        def env_asset_host(env, host)
          look_for = "\nconfig.action_controller.asset_host                  = \"#{host}\"\n"
          logger.asset_host  "map.config.action_controller.asset_host = #{host} [#{env}]"
          gsub_file "config/environments/#{env}.rb", /(#{Regexp.escape(look_for)})/mi, ''
        end
        
        def model_meta_programming(model_underscored, model_path, command)
          model_file = File.join('app/models', model_path, model_underscored + '.rb')
          look_for = "\n  #{command}\n"
          logger.model_update "#{command} [#{model_underscored + '.rb'}]"
          gsub_file model_file, /(#{Regexp.escape(look_for)})/mi, ''
        end
        
        def migration_indexing(model_plural_underscored, command)
          migration_directory('db/migrate')
          migration_files = existing_migrations("create_#{model_plural_underscored}")
          
          migration_files.each do |file_path|
            migration_file = file_path
            look_for = "\n    #{command}\n"
            logger.migration_update "#{command} [#{file_path}]"
            gsub_file migration_file, /(#{Regexp.escape(look_for)})/mi, ''
          end
        end
      end

      module List

        def route_custom_resource(resource, parameter_string)
          resource_list = "#{resource.to_sym.inspect}, #{parameter_string}"
          logger.route "map.resources #{resource_list}"
        end
        
        def env_asset_host(env, host)
          logger.asset_host  "map.config.action_controller.asset_host = #{host} [#{env}]"
        end
        
        def model_meta_programming(model_underscored, model_path, command)
          logger.model_update "#{command} [#{model_underscored + '.rb'}]"
        end
        
        def migration_indexing(model_plural_underscored, command)
          migration_directory('db/migrate')
          migration_files = existing_migrations("create_#{model_plural_underscored}")

          migration_files.each do |file_path|
            migration_file = file_path
            logger.migration_update "#{command} [#{file_path}]"
          end
        end
      end
    end
  end
end