# coding: utf-8
require "jekyll-typescript/config"
require "jekyll-typescript/handler"

Jekyll::Hooks.register :site, :after_reset do |site|
  config = JekyllTypescript::Config.new(site.config)
  config.in_source_build.each do |build_info|
    source_dir = build_info["source_dir"] || config.default_source_dir
    source_file = build_info["source_file"]
    destination = config.site_source / build_info["destination"]
    browserify = build_info["browserify"]
    handler = JekyllTypescript::Handler.new(config, source_dir)
    handler.create_in_source(source_file, destination, browserify)
  end
end
