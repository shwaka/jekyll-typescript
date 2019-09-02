require "json"

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
        handler = JekyllTypescript::Handler.new(ts_dir, build_dir)
        return handler.get_target_code(data["source"], data["browserify"])
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
