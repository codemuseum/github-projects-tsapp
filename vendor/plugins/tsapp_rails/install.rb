# Install a tsapp.yml file into the local config directory.
# If a config file already exists, print a warning and exit.

src_config_file = File.join(File.dirname(__FILE__),'config', "tsapp.yml.sample")
dest_config_file = File.join("config", "tsapp.yml") 

if File::exists? dest_config_file
  STDERR.puts "\nA config file already exists at #{dest_config_file}.\n"
else
  license_key = "PASTE_YOUR_KEY_HERE"
  yaml = File.read(src_config_file)
  File.open( dest_config_file, 'w' ) do |out|
    out.puts yaml
  end
  
  puts IO.read(File.join(File.dirname(__FILE__), 'README'))
  puts "\n--------------------------------------------------------\n"
  puts "Installing a default configuration file in the 'config' directory."
  puts "For your app to work properly, you must enter your api and secret keys."
  puts "See #{dest_config_file}"
  puts "Your application will get api and secret keys when you register your application"
  puts "at www.thrivesmartdev.com (for apps in development) and www.thrivesmarthq.com (for production apps)."
end  
