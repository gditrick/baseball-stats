require 'rake'
require 'rake/clean'

NAME = 'sequel'
VERS = lambda do
  require File.expand_path("../libversion", __FILE__)
  BaseballStats.version
end
CLEAN.include ["**/.*.sw?", "coverage", "www/public/*.html", "www/public/rdoc*", '**/*.rbc']

begin
  begin
    # RSpec 1
    require "spec/rake/spectask"
    spec_class = Spec::Rake::SpecTask
    spec_files_meth = :spec_files=
    spec_opts_meth = :spec_opts=
  rescue LoadError
    # RSpec 2
    require "rspec/core/rake_task"
    spec_class = RSpec::Core::RakeTask
    spec_files_meth = :pattern=
    spec_opts_meth = :rspec_opts=
  end

  spec = lambda do |name, files, d|
    lib_dir = File.join(File.dirname(File.expand_path(__FILE__)), 'lib')
    ENV['RUBYLIB'] ? (ENV['RUBYLIB'] += ":#{lib_dir}") : (ENV['RUBYLIB'] = lib_dir)

    #desc "#{d} with -w, some warnings filtered"
    #task "#{name}_w" do
    #  ENV['RUBYOPT'] ? (ENV['RUBYOPT'] += " -w") : (ENV['RUBYOPT'] = '-w')
    #  rake = ENV['RAKE'] || "#{FileUtils::RUBY} -S rake"
    #  sh "#{rake} #{name} 2>&1 | egrep -v \"(spec/.*: warning: (possibly )?useless use of == in void context|: warning: instance variable @.* not initialized|: warning: method redefined; discarding old|: warning: previous definition of)|rspec\""
    #end

    desc d
    spec_class.new(name) do |t|
      t.send spec_files_meth, files
      t.send spec_opts_meth, ENV['BASEBALL_STATS_SPEC_OPTS'].split if ENV['BASEBALL_STATS_SPEC_OPTS']
    end
  end

  spec_with_cov = lambda do |name, files, d, &b|
    spec.call(name, files, d)
    if RUBY_VERSION < '1.9'
      t = spec.call("#{name}_cov", files, "#{d} with coverage")
      t.rcov = true
      t.rcov_opts = File.file?("spec/rcov.opts") ? File.read("spec/rcov.opts").split("\n") : []
      b.call(t) if b
    else
      desc "#{d} with coverage"
      task "#{name}_cov" do
        ENV['COVERAGE'] = '1'
        Rake::Task[name].invoke
      end
    end
    t
  end

  task :default => [:spec]
  spec_with_cov.call("spec", Dir["spec/{commands,models}/*_spec.rb"], "Run command and model specs"){|t| t.rcov_opts}
  spec.call("spec_bin", ["spec/bin_spec.rb"], "Run bin/mlb specs")
  spec.call("spec_command", Dir["spec/commands/*_spec.rb"], "Run command specs")
  spec.call("spec_model", Dir["spec/models/*_spec.rb"], "Run model specs")
rescue LoadError
  task :default do
    puts "Must install rspec to run the default task (which runs specs)"
  end
end

desc "Print baseball-stats version"
task :version do
  puts VERS.call
end

desc "Check syntax of all .rb files"
task :check_syntax do
  Dir['**/*.rb'].each{|file| print `#{FileUtils::RUBY} -c #{file} | fgrep -v "Syntax OK"`}
end
