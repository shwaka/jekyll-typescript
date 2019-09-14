# coding: utf-8
require "jekyll-typescript/config"
require "jekyll-typescript/handler"
require "jekyll-watch"

# in-source build creates .js files to the place where Watcher is watching
# The following patch prevents these files to be watched
module Jekyll
  module Watcher
    alias _orig__to_exclude to_exclude
    def to_exclude(options)
      config = JekyllTypescript::Config.new(options)
      destinations = config.in_source_build.map do |build_info|
        (config.site_source / build_info["destination"]).to_s
      end
      return _orig__to_exclude(options) + destinations
    end
  end
end

Jekyll::Hooks.register :site, :after_reset do |site|
  config = JekyllTypescript::Config.new(site.config)
  config.in_source_build.each do |build_info|
    source_dir = build_info["source_dir"] || config.default_source_dir
    destination = config.site_source / build_info["destination"]
    handler = JekyllTypescript::Handler.new(config, source_dir)
    handler.create_in_source(destination)
  end
end
