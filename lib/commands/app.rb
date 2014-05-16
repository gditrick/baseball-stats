require_relative 'config'
require_relative 'db'

module BaseballStats
  class App < Thor
    register(Config, :config, 'config SUBCOMMAND', 'Application configuration commands')
    register(Db, :db, 'db SUBCOMMAND', 'Application database commands')

    desc 'init', 'Initializes the application'
    def init
      app = Application.new
      app.config = invoke BaseballStats::Config, :load_config
      app.db = invoke BaseballStats::Db, [:connect, app.config.database]
      invoke BaseballStats::Db, [:migrate, app.db, app.config.schema_scripts_path]
      Dir.glob(File.join(File.expand_path('../../models',__FILE__), '*.rb')).each {|f| load(f) }
      invoke BaseballStats::Db, [:seed, app.config.db_seed_file]
#      invoke BaseballStats::Data, [:load_data, app.config.data.in.path]
      app
    end
  end
end
