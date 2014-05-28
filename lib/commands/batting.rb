require_relative 'app'

module BaseballStats
  class Batting < Thor
    LEAGUE_IDS=%w( AL NL )
    TEAM_IDS=%w( ARI ATL BAL BOS CHA CHN CIN CLE COL DET FLO HOU KCA LAA LAN MIA
                 MIL MIN NYA NYN OAK PHI PIT SDN SEA SFN SLN TBA TEX TOR WAS)

    desc 'avg OPTIONS', 'Batting statistics sorted by avg'
    method_option :year, aliases: '-y',
                         default: Time.now.year,
                         desc: 'year of the stats'
    method_option :league, aliases: '-l',
                           enum: LEAGUE_IDS,
                           desc: 'show stats for a specific league'
    method_option :team, aliases: '-t',
                         enum: TEAM_IDS,
                         desc: 'show stats for a specific team'
    method_option :restrict, aliases: '-r',
                             default: 400,
                             type: :numeric,
                             banner: 'AB | --no-restrict',
                             desc: 'restrict stats to a minimum AB (at_bats)'
    def avg
      BaseballStats::App.new.invoke(:init)
        
      stats = BattingStat.for_year(options[:year]) if options[:year]
      stats = stats.for_league(options[:league]) if options[:league]
      stats = stats.for_team(options[:team]) if options[:team]
      stats = stats.for_player(options[:player]) if options[:player]

      puts BattingStatFormatter.new(:average, report_object, stats, options).out
    end

    desc 'slug OPTIONS', 'Batting statistics sorted by slugging'
    method_option :year, aliases: '-y',
                         default: Time.now.year,
                         desc: 'year of the stats'
    method_option :league, aliases: '-l',
                           enum: LEAGUE_IDS,
                           desc: 'show stats for a specific league'
    method_option :team, aliases: '-t',
                         enum: TEAM_IDS,
                         desc: 'show stats for a specific team'
    method_option :restrict, aliases: '-r',
                             default: 400,
                             type: :numeric,
                             banner: 'AB | --no-restrict',
                             desc: 'restrict stats to a minimum AB (at_bats)'
    def slug
      BaseballStats::App.new.invoke(:init)
        
      stats = BattingStat.for_year(options[:year]) if options[:year]
      stats = stats.for_league(options[:league]) if options[:league]
      stats = stats.for_team(options[:team]) if options[:team]
      stats = stats.for_player(options[:player]) if options[:player]

      puts BattingStatFormatter.new(:slugging, report_object, stats, options).out
    end

    desc 'player PLAYER OPTIONS', 'Batting stats for player'
    method_option :year, aliases: '-y',
                  desc: 'show only a specific year'
    def player(player_id)
      BaseballStats::App.new.invoke(:init)
        
      player = Player[id: player_id]
      if player
        stats = BattingStat.for_player(player)
        stats = stats.for_year(options[:year]) if options[:year]

        puts BattingStatFormatter.new(:year, player, stats, options).out
      else
        puts "No player with id: #{player_id}"
      end
    end

    desc 'triple-crown OPTIONS', 'Triple crown winner(s)'
    method_option :year, aliases: '-y',
                         default: Time.now.year - 1,
                         desc: 'year of the stats'
    method_option :league, aliases: '-l',
                           enum: LEAGUE_IDS,
                           desc: 'show for a specific league'
    method_option :team, aliases: '-t',
                         enum: TEAM_IDS,
                         desc: 'show for a specific team'
    method_option :restrict, aliases: '-r',
                             default: 400,
                             type: :numeric,
                             banner: 'AB | --no-restrict',
                             desc: 'restrict stats to a minimum AB (at_bats)'
    method_option :expand, aliases: '-e',
                           default: false,
                           type: :boolean,
                           desc: 'expand showing leaders in each category'
    method_option :top, aliases: '-T',
                        default: 3,
                        type: :numeric,
                        banner: 'N',
                        desc: 'when expand show only the top N leaders'
    def triple_crown
      BaseballStats::App.new.invoke(:init)
        
      stats = BattingStat.for_year(options[:year])
      stats = stats.for_league(options[:league]) if options[:league]
      stats = stats.for_team(options[:team]) if options[:team]

      puts TripleCrownFormatter.new(report_object, stats, options).out
    end

    private

    def report_object
      case
        when (options[:league] and options[:team].nil?) then
          League[options[:league]]
        when options[:team] then
          options[:league] ||=
              BattingStat.where(team_id: options[:team], year: options[:year]).first.league.id
          Team[options[:team], options[:league]]
        when options[:player] then
          Player[options[:player]]
        else
          BattingStat.new
      end
    end
  end
end
