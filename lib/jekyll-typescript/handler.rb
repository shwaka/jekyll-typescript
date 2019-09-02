# coding: utf-8
require "pathname"
require "rake"

module JekyllTypescript
  class Handler
    def initialize(ts_dir, build_dir)
      # ts_dir, build_dir: Pathname or string
      @ts_dir = Pathname.new(ts_dir)
      @build_dir = Pathname.new(build_dir)
    end

    def get_target_code(ts_rel_path, browserify)
      target = get_target_path(ts_rel_path, browserify)
      rake(target.to_s)
      return target.read
    end

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

        jsfile_list.each{|jsfile|
          rake_app.define_task Rake::FileTask, {jsfile => tsfile_list} do |t|
            puts "Creating #{jsfile} from #{tsfile_list}..."
            `tsc --outDir #{@build_dir}`
          end
          browserified_jsfile = jsfile.sub(/\.js$/, ".browserified.js")
          rake_app.define_task Rake::FileTask, {browserified_jsfile => jsfile} do |t|
            puts "Browserifying #{jsfile}..."
            `browserify #{jsfile} -o #{browserified_jsfile}`
          end
        }
      end
    end
  end
end
