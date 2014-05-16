require File.expand_path('../../config/boot', __FILE__)
require_relative 'application'
require_relative 'commands'

module BaseballStats
  class MLB < Thor
    namespace :mlb
    register(Batting, :batting, "batting SUBCOMMAND", "Player batting awards")
  end
end

BaseballStats::MLB.start
