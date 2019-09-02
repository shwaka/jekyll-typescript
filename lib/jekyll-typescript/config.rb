require "pathname"

module JekyllTypescript
  class Config
    def initialize(site_config)
      @site_config = site_config
      @site_source = Pathname(site_config["source"])
      @ts_config = site_config["typescript"]
      @build_dir_base = @site_source / @ts_config["build_dir"]
    end

    def add_exclude
      @site_config["exclude"].push(@build_dir_base.to_s).uniq!
    end

    def get_build_dir(ts_dir_relative)
      return @build_dir_base / ts_dir_relative
    end

    def get_ts_dir(ts_dir_relative)
      return @site_source / ts_dir_relative
    end

    def source_dir
      # temporary
      @ts_config["source_dir"]
    end
  end
end

Jekyll::Hooks.register :site, :after_init do |site|
  config = JekyllTypescript::Config.new(site.config)
  config.add_exclude
end
