# CAUTION!
This repository is under development.
If you use this repository,
you have to be very careful and patient with incompatible updates.

- APIs may be changed without backward compatibility.
  Even the names of the repository and gem may be also changed.
- Not published to Rubygems.org.
- No documentation is provided.
- `example/` directory may be outdated.


# Aim
This gem aims to provide a tool to use `typescript` in `jekyll` as simple as possible.
The word "simple" means that
no complex frameworks (such as `webpack`) are needed.
This should be useful for small projects.

# Usage
I'm not sure, but you may need to add `bundle exec` before `jekyll` commands.
(i.e. `bundle exec jekyll build`)

## `example/`
In the `example/` directory, you can find the simplest example.
In order to be not affected by updates, a commit hash is specified in the `Gemfile`.

1. `bundle update`
2. `jekyll build` (or `jekyll serve`)

## `test/`
This directory is used for a test during development.
Hence this should be kept to be up-to-date.
Run `bundle update` and `jekyll build` (or `jekyll serve`) in that directory.

# Requirements
- jekyll
- rake
- tsc
- browserify (optional)

Tested on

- Ubuntu 16.04
- ruby 2.6.3
- jekyll 4.0.0
- tsc 3.5.3

# Configuration
## `_config.yml`
```yml
plugins:
  - jekyll-typescript
typescript:  # optional
  build_dir: .tsbuild  # optional, default: .tsbuild
  source_dir:  # required
    - _ts
    - _ts2
  hooks:  # optional
    - container: site  # required
      event: post_read  # required
      source_dir: _ts  # optional, default: the first value of source_dir
      source_file: test.ts  # required
      site_json_file: site.json  # optional, default: null
  in_source_build:  # optional
    - source_dir: _ts  # optional, default: the first value of source_dir
      source_file: test.ts  # required
      destination: js/generated/test.js  # required
      browserify: true  # optional, default: false
```

## `.ts` file with front matter
```
---
---
{
  "source": "foo.ts",  # required
  "browserify": true   # optional, default: false
}
```

# TODO
- `_config.yml` や `*.ts` 内の設定に漏れがあった場合のエラーメッセージ
- gemspec 内の `files` が足りてないけど大丈夫？
  GitHub からインストールしている場合は平気？
- GitHub Pages に対応する
    - 当然 GitHub Pages では(一部の例外を除いて) plugin を実行できないので，
      `.js` ファイルを local で生成して，ソースコードとして(`_site` 外に)出力する．
    - 設定は `hooks` みたいに `_config.yml` で行うと良さそう．
      名前は何が良いんだろう？ `in_source_build` みたいな感じ？
    - そもそも， `_config.yml` の `plugins` に無効なプラグインが書かれていた場合の挙動ってどうなる？
        - 単にそれを無視する？
        - エラーを吐いて build 自体止まってしまう？
    - 参考: [Dependency versions | GitHub Pages](https://pages.github.com/versions/)
      ここに載っている plugins だけが使える？
    - in-source build が `jekyll serve` での2回目以降の build で走らない．
      hook を `:site, :after_reset` にすれば2回目以降も走るけど，
      そのままだと無限ループになってしまう．
      rake を使えば多分2回にはできる．1回にするにはどうしたら良いんだろう…？
