require File.expand_path('../../config/boot', __FILE__)

libpath = File.expand_path(File.join('..'),__FILE__)
$:.unshift(libpath) unless $:.include?(libpath)

require 'application'
require 'commands'

module BaseballStats
  class MLB < Thor
    namespace :mlb
    register(Batting, :batting, "batting SUBCOMMAND", "Player batting awards")
  end
end

BaseballStats::MLB.start
