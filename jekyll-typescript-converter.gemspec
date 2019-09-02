Gem::Specification.new do |s|
  s.name = 'jekyll-typescript-converter'
  s.version = '0.2.0'
  s.summary = "TypeScript converter and hooks for Jekyll"
  s.description = "This gem converts TypeScript sources to JavaScript by using tsc (and browserify)."
  s.authors = ["Shun Wakatsuki"]
  s.email = 'shun.wakatsuki@gmail.com'
  s.files = ["lib/jekyll-typescript.rb"]
  s.homepage = 'https://github.com/shwaka/jekyll-typescript'
  s.license = 'MIT'
  s.add_dependency "rake"
end
