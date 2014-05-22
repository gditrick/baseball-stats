require_relative 'app'

module BaseballStats
  class Batting < Thor
    desc 'avg OPTIONS', 'Batting sorted by avg of league, team or player'
    method_option :year, default: Time.now.year
    method_option :league, aliases: '-l'
    method_option :team, aliases: '-t'
    method_option :player, aliases: '-p'
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
    method_option :year, default: Time.now.year
    method_option :league, aliases: '-l'
    method_option :team, aliases: '-t'
    method_option :player, aliases: '-p'
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

    desc 'triple-crown <year>', 'Triple crown winner for <year> and <league>'
    option :year, default: Time.now.year
    option :league
    def triple_crown
      BaseballStats::App.new.invoke(:init)
      pp "Triple Crown"
      pp "logger: #{@logger}"
      pp "Player count: #{Player.count}"
      pp "Batting Stat count: #{BattingStat.count}"
      pp Player.count
      p = Player['phillan01']
      pp "#{p.first_name} #{p.last_name}" 
      pp "Average: #{p.batting_stats_dataset.for_year('2008').for_team('CIN').average}"
      pp "Slugging: #{p.batting_stats_dataset.for_year('2008').for_team('CIN').slugging}"

#      pp Player['phillan01'].batting_stats_dataset.for_year('2008').for_team('CIN').avg.all
      pp Player['phillan01'].batting_stats_dataset.all
      League.all.each do |l|
        pp "#{l.name} Teams:"
        pp l.teams
        puts
      end
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


