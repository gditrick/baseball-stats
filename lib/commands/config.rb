require 'yaml'

module BaseballStats
  class Config < Thor
    desc 'load', 'Loads the application configrations'
    def load_config
      config ||= Hashie::Mash.new
      config.data = YAML.load_file(File.expand_path('../../../config/data.yml', __FILE__))[ENV['APP_ENV'] || 'development']
      config.schema_scripts_path = File.expand_path('../../../db/migrate', __FILE__)
      config.database = YAML.load_file(File.expand_path('../../../config/database.yml', __FILE__))[ENV['APP_ENV'] || 'development']
      config.logger = YAML.load_file(File.expand_path('../../../config/log4r.yml', __FILE__))
      config
    end
  end
end
