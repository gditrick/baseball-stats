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
      League.all.each do |l|
        pp "#{l.name} Teams:"
        pp l.teams
        puts
      end
    end
  end
end


