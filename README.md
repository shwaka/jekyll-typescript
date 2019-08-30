# Caution!
This repository is under development and is not published to Rubygems.org.

# Usage
See the `example/` directory.
Run `bundle update` and `jekyll build` (or `jekyll serve`) in that directory.

# TODO
- `rake` を shell 経由で呼び出しているせいで，
  ユーザー側で `Gemfile` に `gem 'rake'` を書かないといけない…？
- 毎回 `browserify` してるのは無駄
    - 適切に cache するなどして回避する
    - `browserify` も `Rakefile` に組込む？
