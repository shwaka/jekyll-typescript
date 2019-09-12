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

  def test
    if expected == :noerror
      assert_noerror
    elsif expected == :error
      assert_error
    else
      msg = "Expected result is not set"
      @@error_list << [@dir, msg]
    end
  end

  def assert_noerror
    Dir.chdir(@@root_dir / @dir)
    `jekyll build 2>&1`
    if $?.exitstatus != 0
      msg = "Expected: noerror, Actual: error"
      @@error_list << [@dir, msg]
    end
  end

  def assert_error
    Dir.chdir(@@root_dir / @dir)
    output = `jekyll build --trace 2>&1`
    if $?.exitstatus == 0
      msg = "Expected: error, Actual: noerror"
      @@error_list << [@dir, msg]
    else
      regexp = Regexp.new(@@data["error"][@dir.to_s]["error_msg_regexp"])
      if !(regexp =~ output)
        msg = <<EOS
Error occurred as expected, but wrong error message
Expected regexp: #{regexp}
EOS
        @@error_list << [@dir, msg]
      end
    end
  end

  def expected
    noerror = (@@data["noerror"] || {}).key?(@dir.to_s)
    error = (@@data["error"] || {}).key?(@dir.to_s)
    if noerror && error
      raise "duplicate"
    elsif noerror
      return :noerror
    elsif error
      return :error
    else
      return nil
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
                 .map{|f| Pathname.new(f) }

    dir_list.each do |dir|
      test_dir = TestDir.new(dir)
      test_dir.test
    end
  end

  def self.show
    if @@error_list.length == 0
      puts "Success!"
    else
      puts "Failed in the following directories:"
      puts @@error_list.map{|e| e[0].to_s}.join(" ")
      @@error_list.each{|e|
        puts ""
        puts "[#{e[0]}]"
        puts e[1]
      }
    end
  end
end

test
