require 'rubygems'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path(File.join('..', '..', 'Gemfile'), __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

Bundler.require(:default, ENV['APP_ENV'] || 'test')

libpath = File.expand_path(File.join('..', 'lib'),__FILE__)
$:.unshift(libpath) unless $:.include?(libpath)

require 'commands/config'
require 'commands/db'

config = BaseballStats::Config.new.invoke(:load_config)
db_commands = BaseballStats::Db.new
db = db_commands.invoke :connect, [config.database]
db_commands.invoke :migrate, [db, config.schema_scripts_path]

        
Dir[File.expand_path(File.join("..", "support", "**", "*.rb"), __FILE__)].each { |f| load f }
