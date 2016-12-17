require "hiser/version"
require 'fileutils'
require 'retrospec/plugins/v1/module_helpers'
require 'hiera'
require 'json'
require 'yaml'
require 'retrospec'

module Hiser
  class Cli
    include Retrospec::Plugins::V1::ModuleHelpers

    def self.generate(path)
      instance = Hiser::Cli.new
      instance.generate_files(path)
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

    def generate_files(path, spec_object=nil)
      safe_create_module_files(template_dir, path, spec_object)
    end

    private

    # returns the path to the templates
    # looks inside the gem path templates directory
    def template_dir
      File.expand_path(File.join(File.dirname(File.dirname(__FILE__)), 'lib', 'templates'))
    end

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
