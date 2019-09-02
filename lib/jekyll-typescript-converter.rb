# coding: utf-8
require "pathname"
require "json"
require "rake"

Jekyll::Hooks.register :site, :after_init do |site|
  build_dir = site.config["typescript"]["build_dir"]
  site.config["exclude"].push(build_dir).uniq!
end

module Jekyll
  module Converters
    class TypeScriptConverter < Converter
      def matches(ext)
        ext =~ /^\.ts$/i
      end

      def output_ext(ext)
        ".js"
      end

      def convert(content)
        data = JSON.parse(content)
        validate_data(data)
        config = @config["typescript"]
        site_source_path = Pathname.new(site_source)
        # ts source directory
        ts_dir = site_source_path / config["source_dir"]
        # build target
        build_dir = site_source_path / config["build_dir"]
        ENV["TSBUILD"] = build_dir.to_s
        target = build_dir / get_target_filename(data)
        # rake
        Dir.chdir(ts_dir)
        puts "Running tsc (rake)..."
        # system("bundle exec rake")
        Rake.with_application do |rake|
          # Rake.with_application の定義 (in rake/rake_module.rb) のコメント参照
          rake.load_rakefile
          rake[target.to_s].invoke
        end
        return target.read
      end

      private
      def site_source
        @site_source ||= File.expand_path(@config["source"]).freeze
      end

      def validate_data(data)
        if !data.has_key?("source")
          throw '"source" not found'
        end
      end

      def get_target_filename(data)
        # return content.strip.sub(/\.ts$/, ".js")
        browserify = data["browserify"]
        if browserify
          ext = ".browserified.js"
        else
          ext = ".js"
        end
        return data["source"].strip.sub(/\.ts$/, ext)
      end
    end
  end
end
