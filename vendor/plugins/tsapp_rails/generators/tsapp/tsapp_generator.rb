require 'generator_commands'

class TsappGenerator < Rails::Generator::NamedBase
  default_options :skip_timestamps => false, :skip_migration => false

  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name,
                :asset_host
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super
    
    # Install hooks for custom manifest commands
    Rails::Generator::Commands::Create.send   :include,  ThriveSmart::Generator::Commands::Create
    Rails::Generator::Commands::Destroy.send  :include,  ThriveSmart::Generator::Commands::Destroy
    Rails::Generator::Commands::List.send     :include,  ThriveSmart::Generator::Commands::List

    @asset_host = @args.shift
    @args.unshift 'urn:string' # Make sure our uber-important URN is here
    @controller_name = @name.pluralize

    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name=base_name.singularize
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions(controller_class_path, "#{controller_class_name}Controller", "#{controller_class_name}Helper")
      m.class_collisions(class_path, "#{class_name}")

      # Controller, helper, views, test and stylesheets directories.
      m.directory(File.join('app/models', class_path))
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory(File.join('app/helpers', controller_class_path))
      m.directory(File.join('app/views', controller_class_path, controller_file_name))
      m.directory(File.join('app/views/layouts', controller_class_path))
      m.directory(File.join('test/functional', controller_class_path))
      m.directory(File.join('test/unit', class_path))
      # m.directory(File.join('public/stylesheets', class_path))

      for action in page_object_views
        m.template(
          "view_#{action}.html.erb",
          File.join('app/views', controller_class_path, controller_file_name, "#{action}.html.erb")
        )
      end

      # Layout and stylesheet.
      m.template('layout.html.erb', File.join('app/views/layouts', controller_class_path, "#{controller_file_name}.html.erb"))
      # m.template('style.css', 'public/stylesheets/scaffold.css')

      m.template(
        'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      )

      m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      m.template('helper.rb',          File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb"))

      m.route_custom_resource controller_file_name, ':member => { :update_valid => :put }, :collection => { :create_valid => :post, :duplicate => :post, :duplicate_valid => :post }'

      m.env_asset_host 'production', @asset_host
      m.env_asset_host 'development', @asset_host

      m.dependency 'model', [name] + @args, :collision => :skip
      
      # Stack order
      m.model_meta_programming controller_underscore_name.singularize, class_path, 
        "self.caching_default = :page_object_update \#[in :forever, :page_object_update, :any_page_object_update, 'data_update[datetimes]', :never, 'interval[5]']"
      m.model_meta_programming controller_underscore_name.singularize, class_path, 
        "include ThriveSmartObjectMethods"

     m.migration_indexing controller_underscore_name, "add_index :#{controller_underscore_name}, :urn"
    end
  end

  protected    
    
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} tsapp ModelName asset_host [field:type, field:type]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-timestamps",
             "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
      opt.on("--skip-migration",
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
    end

    def page_object_views
      %w[ show edit ]
    end

    def model_name
      class_name.demodulize
    end
end
