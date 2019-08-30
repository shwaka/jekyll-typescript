require "pathname"
require "json"

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
        config = @config["typescript"]
        site_source_path = Pathname.new(site_source)
        # ts source directory
        ts_dir = site_source_path / config["source_dir"]
        # build target
        build_dir = site_source_path / config["build_dir"]
        ENV["TSBUILD"] = build_dir.to_s
        target = build_dir / get_target_filename(content)
        # make
        Dir.chdir(ts_dir)
        puts "Running tsc (make)..."
        system("make")
        if browserify(content)
          return `browserify #{target.to_s}`
        else
          return target.read
        end
      end

      private
      def site_source
        @site_source ||= File.expand_path(@config["source"]).freeze
      end

      def get_target_filename(content)
        # return content.strip.sub(/\.ts$/, ".js")
        data = JSON.parse(content)
        return data["target"].strip.sub(/\.ts$/, ".js")
      end

      def browserify(content)
        data = JSON.parse(content)
        return data["browserify"]
      end
    end
  end
end
