require 'rubygems'
require 'simplecov'

SimpleCov.start do
  add_group "Models", "lib/models"
  add_group "Commands", "lib/commands"
  add_group "Formatters", "lib/formatters"

  add_filter "/db/"
  add_filter "/spec/"
end
     
ENV['BUNDLE_GEMFILE'] ||= File.expand_path(File.join('..', '..', 'Gemfile'), __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

Bundler.require(:default, ENV['APP_ENV'] || 'test')

libpath = File.expand_path(File.join('..', 'lib'),__FILE__)
$:.unshift(libpath) unless $:.include?(libpath)

require "commands"

config = BaseballStats::Config.new.invoke(:load_config)
db_commands = BaseballStats::Db.new
db = db_commands.invoke :connect, [config.database]
db_commands.invoke :migrate, [db, config.schema_scripts_path]

        
FileList[File.expand_path(File.join("..", "..", "lib", "models", "**", "*.rb"), __FILE__)].each { |f| load f }
FileList[File.expand_path(File.join("..", "..", "lib", "formatters", "**", "*.rb"), __FILE__)].each { |f| load f }
Dir[File.expand_path(File.join("..", "factories", "**", "*.rb"), __FILE__)].each { |f| load f }
Dir[File.expand_path(File.join("..", "support", "**", "*.rb"), __FILE__)].each { |f| load f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
