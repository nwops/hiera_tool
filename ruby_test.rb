
#!/usr/bin/env ruby
# Author: Corey Osman
# Date: 10/3/16
# Purpose: A simple script that uses hiera data lookups to create
#          json or yaml serialized files with custom object mappings
#          defined in the hiera common.yaml file

require 'fileutils'
begin
  require 'hiera'
rescue LoadError
  puts "You must have the hiera gem installed: gem install hiera"
  exit 1
end
require 'json'
require 'yaml'

# creates a new hiera object
def hiera
  # create a new instance based on config file
  @hiera ||= Hiera.new(:config => "./hiera.yaml")
end

# lookups the list of env_scopes via hiera
def env_scopes
  @env_data || hiera.lookup(static_names['scopes'], '', {})
end

# lookups the map called output_object_files and returns a key/value pair
# of map types and the designated output file
def files
  @files ||= hiera.lookup(static_names['object_files'], '', {})
end

def static_names
  @static_names ||= hiera.lookup("static_names", '', {})
end

# write the given data to the given file name
# also encodes in yaml or json by detecting the extension name
def write_data(file_name, data)
  file_type = File.extname(file_name).downcase
  if file_type == '.json'
    File.write(file_name, JSON.pretty_generate(data))
  else
    File.write(file_name, data.to_yaml)
  end
  puts "Wrote file: #{file_name}"
end

# generate a file based on the map_name
# uses the map name to look up the data via hiera
def generate_file(map_name, file_name)
  env_scopes.each do | scope_name, scope |
    data = {}
    FileUtils.mkdir(scope_name) unless File.exists?(scope_name)
    file_name_path = File.join(scope_name, file_name)
    obj_map = hiera.lookup(map_name, '', scope)
    write_data(file_name_path, obj_map)
  end
end

# produces all the files identified in the output_object_files hash
files.each { | map_name, file_name | generate_file(map_name, file_name) }
