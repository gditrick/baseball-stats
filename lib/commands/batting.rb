require_relative 'app'

module BaseballStats
  class Batting < Thor
    desc 'avg OPTIONS', 'Batting sorted by avg of league, team or player'
    method_option :year, default: Time.now.year, aliases: '-y'
    method_option :league, aliases: '-l'
    method_option :team, aliases: '-t'
    method_option :restrict, default: 400, type: :numeric
    def avg
      BaseballStats::App.new.invoke(:init)
        
      object = report_object

      stats = BattingStat.for_year(options[:year]) if options[:year]
      stats = stats.for_league(options[:league]) if options[:league]
      stats = stats.for_team(options[:team]) if options[:team]
      stats = stats.for_player(options[:player]) if options[:player]

      puts BattingStatFormatter.new(:average, object, stats, options[:year], options[:restrict]).out
    end

    desc 'slug OPTIONS', 'Batting sorted by slugging of league, team or player'
    method_option :year, default: Time.now.year, aliases: '-y'
    method_option :league, aliases: '-l'
    method_option :team, aliases: '-t'
    method_option :restrict, default: 400, type: :numeric
    def slug
      BaseballStats::App.new.invoke(:init)
        
      object = report_object

      stats = BattingStat.for_year(options[:year]) if options[:year]
      stats = stats.for_league(options[:league]) if options[:league]
      stats = stats.for_team(options[:team]) if options[:team]
      stats = stats.for_player(options[:player]) if options[:player]

      puts BattingStatFormatter.new(:slugging, object, stats, options[:year], options[:restrict]).out
    end

    desc 'player PLAYER OPTIONS', 'Batting stats for player'
    method_option :year, aliases: '-y'
    def player(player_id)
      BaseballStats::App.new.invoke(:init)
        
      player = Player[id: player_id]
      if player
        stats = BattingStat.for_player(player)
        stats = stats.for_year(options[:year]) if options[:year]

        puts BattingStatFormatter.new(:year, player, stats, options[:year]).out
      else
        puts "No player with id: #{player_id}"
      end
    end

    desc 'triple-crown <year>', 'Triple crown winner for <year> for <league>'
    method_option :year, default: Time.now.year, aliases: '-y'
    method_option :league, aliases: '-l'
    method_option :team, aliases: '-t'
    method_option :restrict, default: 400, type: :numeric
    method_option :expand, default: false, type: :boolean
    def triple_crown
      BaseballStats::App.new.invoke(:init)
        
      object = report_object

      stats = BattingStat.for_year(options[:year]) if options[:year]
      stats = stats.for_league(options[:league]) if options[:league]
      stats = stats.for_team(options[:team]) if options[:team]

      puts TripleCrownFormatter.new(object, stats, options).out
    end

    private

    def report_object
      case
        when options[:league] then
          League[options[:league]]
        when options[:team] then
          Team[options[:team]]
        when options[:player] then
          Player[options[:player]]
        else
          BattingStat.new
      end
    end
  end
end
