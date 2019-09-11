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

# TODO
- `_config.yml` や `*.ts` 内の設定に漏れがあった場合のエラーメッセージ
- gemspec 内の `files` が足りてないけど大丈夫？
  GitHub からインストールしている場合は平気？
