#!/usr/bin/env ruby
require 'pathname'
require 'yaml'

def test
  TestDir.set_data("data.yml")
  current_dir = Pathname.pwd
  TestDir.test_all_subdir(current_dir)
  TestDir.show
end

class TestDir
  @@error_list = []

  def initialize(dir)
    if dir.relative?
      raise "dir must be a full path"
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

  def self.set_data(filename)
    yaml_str = Pathname(filename).read
    @@data = YAML.load(yaml_str)
  end

  def self.test_all_subdir(root_dir)
    Dir.chdir(root_dir)
    dir_list = Dir.glob("*")
                 .select{|f| File.directory? f }
                 .map{|f| root_dir / f }

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
