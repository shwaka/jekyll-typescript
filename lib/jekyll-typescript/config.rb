# coding: utf-8
require "pathname"

module JekyllTypescript
  class Config
    attr_reader :site_source

    def initialize(site_config)
      @site_config = site_config
      @site_source = Pathname(site_config["source"])
      @ts_config = site_config["typescript"]
      @build_dir = @ts_config["build_dir"] || ".tsbuild"
      # @build_dir_base = @site_source / @build_dir
    end

    def add_exclude
      # @site_config["exclude"].push(@build_dir_base.to_s)
      get_source_dir_list.each do |dir|
        @site_config["exclude"].push((@site_source / dir / @build_dir).to_s)
      end
      @site_config["exclude"].uniq!
    end

    def get_source_dir_list
      source_dir = @ts_config["source_dir"]
      if source_dir.nil?
        raise "source_dir is required"
      end
      if source_dir.is_a?(Array)
        return source_dir
      else
        return [source_dir]
      end
    end

    def get_build_dir(ts_dir_relative)
      return @site_source / ts_dir_relative / @build_dir
      # return @build_dir_base / ts_dir_relative
    end

    def get_ts_dir(ts_dir_relative)
      return @site_source / ts_dir_relative
    end

    def default_source_dir
      # @ts_config["default_source_dir"] || "_ts"
      get_source_dir_list[0]
    end

    def hooks
      return @ts_config["hooks"] || []
    end

    def pages
      return @ts_config["pages"] || []
    end

    def in_source_build
      return @ts_config["in_source_build"] || []
    end
  end
end

Jekyll::Hooks.register :site, :after_init do |site|
  config = JekyllTypescript::Config.new(site.config)
  config.add_exclude
end
