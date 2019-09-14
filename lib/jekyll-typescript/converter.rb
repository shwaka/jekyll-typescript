require "json"
require "jekyll-typescript/config"

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
        config = JekyllTypescript::Config.new(@config)
        source_dir = data["source_dir"] || config.default_source_dir
        handler = JekyllTypescript::Handler.new(config, source_dir)
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
