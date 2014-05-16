require 'pp'
require_relative 'batting'


module BaseballStats
  class MLB < Thor
    namespace :mlb

    desc 'batting SUBCOMMAND ...ARGS', 'find batting statistical leaders'
    subcommand "batting", Batting
  end
end


