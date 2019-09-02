Jekyll::Hooks.register :site, :after_init do |site|
  build_dir = site.config["typescript"]["build_dir"]
  site.config["exclude"].push(build_dir).uniq!
end
