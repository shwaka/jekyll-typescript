# coding: utf-8
require "pathname"
require "fileutils"
require "json"
require "rake"

Jekyll::Hooks.register :site, :after_init do |site|
  build_dir = site.config["typescript"]["build_dir"]
  site.config["exclude"].push(build_dir).uniq!
end

module Jekyll
  module Converters
    class TypeScriptHandler
      def initialize(ts_dir, build_dir)
        # ts_dir, build_dir: Pathname
        @ts_dir = ts_dir
        @build_dir = build_dir
      end

      # returns the path to the target file as an object of Pathname
      def get_target_path(data)
        browserify = data["browserify"]
        if browserify
          ext = ".browserified.js"
        else
          ext = ".js"
        end
        relative_path = data["source"].sub(/\.ts$/, ext)
        return @build_dir / relative_path
      end

      def rake(target_name)
        Dir.chdir(@ts_dir)
        # system("bundle exec rake")
        Rake.with_application do |rake_app|
          # Rake.with_application の定義 (in rake/rake_module.rb) のコメント参照
          setup(rake_app)
          rake_app[target_name].invoke
        end
      end

      private
      def setup(rake_app)
        if File.exist?("Rakefile")
          ENV["TSBUILD"] = @build_dir.to_s
          rake_app.load_rakefile
        else
          tsfile_list = Dir["./**/*.ts"]

          # generate .js file by tsc
          jsfile_list = tsfile_list.map do |tsfile|
            basename = tsfile.sub(/\.ts$/, ".js").sub(%r(^\./), "")
            "#{@build_dir}/#{basename}"
          end

          jsfile_list.each{|jsfile|
            rake_app.define_task Rake::FileTask, {jsfile => tsfile_list} do |t|
              puts "Creating #{jsfile} from #{tsfile_list}..."
              `tsc --outDir #{@build_dir}`
            end
            browserified_jsfile = jsfile.sub(/\.js$/, ".browserified.js")
            rake_app.define_task Rake::FileTask, {browserified_jsfile => jsfile} do |t|
              puts "Browserifying #{jsfile}..."
              `browserify #{jsfile} -o #{browserified_jsfile}`
            end
          }
        end
      end
    end

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
        handler = TypeScriptHandler.new(ts_dir, build_dir)
        target = handler.get_target_path(data)
        handler.rake(target.to_s)
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
    end
  end
end
