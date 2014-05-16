require_relative 'app'
require 'pp'

module BaseballStats
  class Batting < Thor
    register(App, :app, 'app SUBCOMMAND', 'Application setup commands')

    desc 'title <year> <league>', 'Batting title for <year> and <league>'
    option :year, default: Time.now.year
    option :league
    def title
    end

    desc 'triple-crown <year>', 'Triple crown winner for <year> and <league>'
    option :year, default: Time.now.year
    option :league
    def triple_crown
      pp "Triple Crown"
      invoke :app, ['init']
      pp Player.all
    end
  end
end


