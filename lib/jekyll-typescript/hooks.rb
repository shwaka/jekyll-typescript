# coding: utf-8
require "jekyll-typescript/config"
require "jekyll-typescript/handler"

Jekyll::Hooks.register :site, :after_init do |site|
  config = JekyllTypescript::Config.new(site.config)
  config.hooks.each do |hook|
    container_name = hook["container"].to_sym
    event_name = hook["event"].to_sym
    source_dir = hook["source_dir"] || config.default_source_dir
    source_file = hook["source_file"]
    handler = JekyllTypescript::Handler.new(config.get_ts_dir(source_dir),
                                            config.get_build_dir(source_dir))
    if (container_name == :site) && (event_name == :after_init)
      handler.run(source_file)
    else
      Jekyll::Hooks.register container_name, event_name do |container|
        handler.run(source_file)
      end
    end
  end
end
