require_relative 'config'
require_relative 'data'
require_relative 'db'

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
      Dir.glob(File.join(File.expand_path('../../models',__FILE__), '*.rb')).each {|f| load(f) }
      db.invoke :seed, [app.config.db_seed_file]
      data.invoke :load_new, [app.config.data.in]
      app
    end
  end
end
