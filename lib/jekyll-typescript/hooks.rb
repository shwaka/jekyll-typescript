# coding: utf-8
require "jekyll-typescript/config"
require "jekyll-typescript/handler"

module JekyllTypescript
  Jekyll::Hooks.register :site, :after_init do |site|
    config = JekyllTypescript::Config.new(site.config)
    config.hooks.each do |hook|
      container_name = hook["container"].to_sym
      event_name = hook["event"].to_sym
      ts_dir_rel = hook["source_dir"] || config.default_source_dir
      ts_rel_path = hook["source_file"]
      site_json_file = hook["site_json_file"]
      handler = JekyllTypescript::Handler.new(config, ts_dir_rel)
      if container_name == :site
        if event_name == :after_init
          handler.run(ts_rel_path, site_json_file, site)
        else
          Jekyll::Hooks.register container_name, event_name do |_site|
            handler.run(ts_rel_path, site_json_file, _site)
          end
        end
      else
        raise 'container_name must be "site"'
      end
    end
  end
end
