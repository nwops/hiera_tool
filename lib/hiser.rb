require "hiser/version"
require 'fileutils'
begin
  require 'hiera'
rescue LoadError
  puts "You must have the hiera gem installed: gem install hiera"
  exit 1
end
require 'json'
require 'yaml'

module Hiser
  class Cli

    def self.generate

    end

    def self.start
      instance = Hiser::Cli.new
      instance.run
    end

    # produces all the files identified in the output_object_files hash
    def run
      files.each do | file_hash|
        file_hash.each {| map_name, file_name | generate_file(map_name, file_name) }
      end
    end

    private

    # creates a new hiera object
    def hiera
      # create a new instance based on config file
      @hiera ||= Hiera.new(:config => "./hiera.yaml")
    end

    # lookups the list of env_scopes via hiera
    def env_scopes
      @env_data || hiera.lookup(settings.fetch('scopes'), '', {})
    end

    # lookups the map called output_object_files and returns a key/value pair
    # of map types and the designated output file
    def files
      @files ||= hiera.lookup(settings.fetch('object_files'), '', {})
    end

    def settings
      @settings ||= hiera.lookup('hiera_tool_settings', '', {})
    end

    def output_dir
      @output_dir ||= settings.fetch('output_directory', 'output_data')
    end

    # write the given data to the given file name
    # also encodes in yaml or json by detecting the extension name
    def write_data(file_path, data)
      file_type = File.extname(file_path).downcase
      if file_type == '.json'
        File.write(file_path, JSON.pretty_generate(data))
      else
        File.write(file_path, data.to_yaml)
      end
      puts "Wrote file: #{file_path}"
    end

    # generate a file based on the map_name
    # uses the map name to look up the data via hiera
    def generate_file(map_name, file_name)
      env_scopes.each do | scope_name, scope |
        dir = File.join(output_dir, scope_name)
        FileUtils.mkdir_p(dir) unless File.exists?(dir)
        file_name_path = File.join(dir, file_name)
        obj_map = hiera.lookup(map_name, '', scope)
        write_data(file_name_path, obj_map)
      end
    end



  end
end
