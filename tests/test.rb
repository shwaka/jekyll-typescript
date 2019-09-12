#!/usr/bin/env ruby
require 'pathname'
require 'yaml'

def test
  current_dir = Pathname.pwd
  TestDir.init("data.yml", current_dir)
  TestDir.test_all_subdir()
  TestDir.show
end

class TestDir
  @@error_list = []

  def initialize(dir)
    if !dir.relative?
      raise "dir must be a relative path"
    end
    @dir = dir
  end

  def assert_success
    Dir.chdir(@dir)
    `jekyll build 2>&1`
    if $?.exitstatus != 0
      @@error_list << @dir
    end
  end

  def self.init(data_filename, root_dir)
    @@root_dir = root_dir
    yaml_str = Pathname(data_filename).read
    @@data = YAML.load(yaml_str)
  end

  def self.test_all_subdir()
    Dir.chdir(@@root_dir)
    dir_list = Dir.glob("*")
                 .select{|f| File.directory? f }
                 .map{|f| @@root_dir / f }

    dir_list.each do |dir|
      test_dir = TestDir.new(dir)
      test_dir.assert_success
    end
  end

  def self.show
    if @@error_list.length == 0
      puts "Success!"
    else
      puts "Error in #{@@error_list.map{|d| d.basename.to_s}}"
    end
  end
end

test
