# coding: utf-8
require "jekyll-typescript/config"
require "jekyll-typescript/handler"

Jekyll::Hooks.register :site, :after_init do |site|
  config = JekyllTypescript::Config.new(site.config)
  config.hooks.each do |hook|
    container_name = hook["container"].to_sym
    event_name = hook["event"].to_sym
    ts_dir_rel = hook["source_dir"] || config.default_source_dir
    ts_rel_path = hook["source_file"]
    handler = JekyllTypescript::Handler.new(config.get_ts_dir(ts_dir_rel),
                                            config.get_build_dir(ts_dir_rel))
    if (container_name == :site) && (event_name == :after_init)
      handler.run(ts_rel_path)
    else
      Jekyll::Hooks.register container_name, event_name do |container|
        handler.run(ts_rel_path)
      end
    end
  end
end
