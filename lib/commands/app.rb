require 'rake'
require 'commands/config'
require 'commands/data'
require 'commands/db'

module BaseballStats
  class App < Thor
    desc 'init', 'Initializes the application'
    def init
      @logger = 'test'
      app = Application.new
      app.config = BaseballStats::Config.new.invoke(:load_config)
      db = BaseballStats::Db.new
      data = BaseballStats::Data.new
      app.db = db.invoke :connect, [app.config.database]

      db.invoke :migrate, [app.db, app.config.schema_scripts_path]

      FileList[File.expand_path(File.join("..", "..", "models", "**", "*.rb"), __FILE__)].each { |f| load f }
      FileList[File.expand_path(File.join("..", "..", "formatters", "**", "*.rb"), __FILE__)].each { |f| load f }

      db.invoke :seed, [app.config.db_seed_file]
      data.invoke :load_new, [app.config.data.in]
      app
    end
  end
end
