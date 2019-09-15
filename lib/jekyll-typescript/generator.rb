require "pathname"
require "jekyll-typescript/config"

module Jekyll
  class PageFromTypeScript < Page
    def initialize(site, page_data)
      @site = site
      @base = site.source
      path = Pathname.new(page_data["destination"])
      @dir = path.dirname.to_s
      @name = path.basename.to_s
      layout = page_data["layout"]
      data = page_data["data"] || {}

      self.process(@name)
      self.read_yaml(File.join(@base, "_layouts"), layout)
      self.data["ts_content"] = generate_content(page_data)
      self.data.merge!(data)
    end

    def generate_content(page_data)
      destination = page_data["destination"]
      config = JekyllTypescript::Config.new(@site.config)
      ts_dir_rel = page_data["source_dir"]
      handler = JekyllTypescript::Handler.new(config, ts_dir_rel, @site)
      cache = page_data["cache"]
      return handler.generate_page(destination, cache)
    end
  end

  class TypeScriptPageGenerator < Generator
    def generate(site)
      config = JekyllTypescript::Config.new(site.config)
      config.pages.each do |page_data|
        # destination = page_data["destination"]
        # layout = page_data["layout"]
        # data = page_data["data"] || {}
        site.pages << PageFromTypeScript.new(site, page_data)
      end
    end
  end
end
