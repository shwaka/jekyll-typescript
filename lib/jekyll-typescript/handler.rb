# coding: utf-8
require "pathname"
require "rake"
require "fileutils"
require "jekyll-typescript/config"

module JekyllTypescript
  class FiltersClass
    extend Jekyll::Filters
  end

  class Handler
    def initialize(config, ts_dir_rel, site = nil)
      # ts_dir, build_dir: Pathname or string
      @config = config
      @ts_dir = Pathname.new(@config.get_ts_dir(ts_dir_rel))
      @build_dir = Pathname.new(@config.get_build_dir(ts_dir_rel))
      @site = site
    end

    def get_target_code(ts_rel_path, browserify)
      # for converter
      target = get_target_path(ts_rel_path, browserify)
      rake(target.to_s)
      return target.read
    end

    def create_in_source(destination_abs_path)
      rake(destination_abs_path)
    end

    def run(ts_rel_path, site_json_file = nil)
      target = get_target_path(ts_rel_path, false)
      rake(target.to_s)
      if site_json_file
        write_site_json(site_json_file)
      end
      Dir.chdir(@build_dir)
      system("node #{target.to_s}")
    end

    def generate_page(destination, cache = false)
      cache_file = page_cache_file(destination)
      if !cache
        FileUtils.rm(cache_file)
      end
      rake(cache_file.to_s)
      return cache_file.read
    end

    # def run_to_s(ts_rel_path, site_json_file = nil)
    #   target = get_target_path(ts_rel_path, false)
    #   rake(target.to_s)
    #   if site_json_file
    #     write_site_json(site_json_file)
    #   end
    #   Dir.chdir(@build_dir)
    #   return `node #{target.to_s}`
    # end

    private
    # returns the path to the target file as an object of Pathname
    def get_target_path(ts_rel_path, browserify)
      # ts_rel_path: string or Pathname
      # browserify: boolean
      if browserify
        ext = ".browserified.js"
      else
        ext = ".js"
      end
      relative_path = ts_rel_path.to_s.sub(/\.ts$/, ext)
      return @build_dir / relative_path
    end

    def rake(target_name)
      Dir.chdir(@ts_dir)
      # system("bundle exec rake")
      Rake.with_application do |rake_app|
        # Rake.with_application の定義 (in rake/rake_module.rb) のコメント参照
        setup(rake_app)
        rake_app[target_name].invoke
      end
    end

    def write_site_json(site_json_file)
      if @site.nil?
        raise "site not specified"
      end
      json_path = @build_dir / site_json_file
      json_content = JekyllTypescript::FiltersClass.jsonify(@site)
      json_path.write(json_content)
    end

    def page_cache_file(destination)
      @build_dir / "page-cache" / destination
    end

    # def prepare_run(target, site_json_file = nil, site = nil)
    #   # prepare to run
    #   rake(target.to_s)
    #   if site_json_file
    #     if site.nil?
    #       raise "site not specified"
    #     end
    #     json_path = @build_dir / site_json_file
    #     json_content = JekyllTypescript::FiltersClass.jsonify(site)
    #     json_path.write(json_content)
    #   end
    #   Dir.chdir(@build_dir)
    #   # system("node #{target.to_s}")
    # end

    def setup(rake_app)
      if File.exist?("Rakefile")
        ENV["TSBUILD"] = @build_dir.to_s
        rake_app.load_rakefile
      else
        tsfile_list = Dir["./**/*.ts"]

        # generate .js file by tsc
        jsfile_list = tsfile_list.map do |tsfile|
          basename = tsfile.sub(/\.ts$/, ".js").sub(%r(^\./), "")
          "#{@build_dir}/#{basename}"
        end

        jsfile_list.each do |jsfile|
          rake_app.define_task Rake::FileTask, {jsfile => tsfile_list} do |t|
            # puts "Creating #{jsfile} from #{tsfile_list}..."
            puts "Creating #{jsfile}"
            `tsc --outDir #{@build_dir}`
          end
          browserified_jsfile = jsfile.sub(/\.js$/, ".browserified.js")
          rake_app.define_task Rake::FileTask, {browserified_jsfile => jsfile} do |t|
            puts "Browserifying #{jsfile}..."
            `browserify #{jsfile} -o #{browserified_jsfile}`
          end
        end

        @config.in_source_build.each do |build_info|
          destination_abs_path = @config.site_source / build_info["destination"]
          ts_rel_path = build_info["source_file"]
          browserify = build_info["browserify"]
          target = get_target_path(ts_rel_path, browserify)
          rake_app.define_task Rake::FileTask, {destination_abs_path => target.to_s} do |t|
            destination_dir = destination_abs_path.parent
            if !destination_dir.exist?
              Dir.mkdir(destination_dir)
            end
            FileUtils.cp(target.to_s, destination_abs_path)
          end
        end

        @config.pages.each do |page_data|
          destination_abs_path = page_cache_file(page_data["destination"])
          ts_rel_path = page_data["source_file"]
          js_file = get_target_path(ts_rel_path, false)
          depend_files = (page_data["depend"] || []).map{|f| (@config.site_source / f).to_s }
          rake_app.define_task Rake::FileTask,
                               {destination_abs_path => [js_file.to_s] + depend_files} do |t|
            site_json_file = page_data["site_json_file"]
            if site_json_file
              write_site_json(site_json_file)
            end
            Dir.chdir(@build_dir)
            FileUtils.mkdir_p(destination_abs_path.dirname)
            result = `node #{js_file.to_s}`
            destination_abs_path.write(result)
          end
        end
      end
    end
  end
end
