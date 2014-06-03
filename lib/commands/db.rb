module BaseballStats
  class Db < Thor
    Sequel.extension :migration

    desc 'connect', 'Makes db connection'
    def connect(server_config)
      Sequel.connect(server_config)
    end

    desc 'migrate', 'Creates db schema'
    def migrate(db, path)
      Sequel::Migrator.apply(db, path)
    end

    desc 'seed', 'Seeds a fresh db'
    def seed(file)
      load(file) if File.exists?(file)
    end
  end
end
