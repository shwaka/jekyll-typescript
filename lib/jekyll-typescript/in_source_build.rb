# coding: utf-8
require "jekyll-typescript/config"
require "jekyll-typescript/handler"

Jekyll::Hooks.register :site, :after_reset do |site|
  config = JekyllTypescript::Config.new(site.config)
  config.in_source_build.each do |build_info|
    source_dir = build_info["source_dir"] || config.default_source_dir
    destination = config.site_source / build_info["destination"]
    handler = JekyllTypescript::Handler.new(config, source_dir)
    handler.create_in_source(destination)
  end
end
