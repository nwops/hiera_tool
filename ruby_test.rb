
#!/usr/bin/env ruby
# Author: Corey Osman
# Date: 10/3/16
# Purpose: A simple script that uses hiera data lookups to create
#          json or yaml serialized files with custom object mappings
#          defined in the hiera common.yaml file


require 'hiera'
require 'json'
require 'yaml'

# creates a new hiera object
def hiera
  # create a new instance based on config file
  @hiera ||= Hiera.new(:config => "./hiera.yaml")
end

# lookups the list of env_scopes via hiera
def env_scopes
  @env_data || hiera.lookup('env_scopes', '', {})
end

# lookups the map called output_object_files and returns a key/value pair
# of map types and the designated output file
def files
  @files ||= hiera.lookup("output_object_files", '', {})
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
    obj_map = hiera.lookup(map_name, '', scope)
    # The map object needs to be a hash
    unless obj_map.instance_of?(Hash)
      puts "#{map_name} is not a hash object"
      exit 1
    end
    # performs a secondary lookup of the value in the obj_map
    # ideally we should use hiera interpolation but that returns a string
    # instead of a ruby object.  By looping through we can perform the same type
    # of interpolation below.
    obj_map.each do | name, key |
      data[name] = hiera.lookup(key, '', scope)
    end
    write_data(file_name, data)
  end
end


# produces all the files identified in the output_object_files hash
files.each { | map_name, file_name | generate_file(map_name, file_name) }
