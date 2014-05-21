class BattingStatFormatter
  TAB="\t"
  PLAYER_HEADER_FORMAT="%s%-30s %4s %4s %4s %3s %3s %3s %3s %3s %5s %5s\n"
  PLAYER_LINE_FORMAT=  "%s%-30s %4d %4d %4d %3d %3d %3d %3d %3d %5s %5s\n"

  attr_writer :order, :object, :stats
  attr_reader :out

  def initialize(order, object, stats)
    @order  = order
    @object = object
    @stats  = stats
    @out    = ""

    case @object
      when League
        league_header(@object, @stats)
        @out << "\n"
        team_stats = @object.teams.map{|a| stats = @stats.dup.where(team: a); stats.calculated_stats=nil; [a, stats]}
        team_stats.reject!{|a| a[1].empty?}
        team_stats.sort!{|a,b| b[1].send(@order) <=> a[1].send(@order)}

        team_stats.each do |team_stat|
          @out << "\n"
          team_header(team_stat[0], team_stat[1], 1)
          players = team_stat[1].map(&:player).uniq
          player_stats = players.map{|a| stats = team_stat[1].dup.where(player: a); stats.calculated_stats=nil; [a, stats]}
          player_stats.reject!{|a| a[1].empty? or a[1].send(@order).nil?}
          player_stats.sort!{|a,b| b[1].send(@order) <=> a[1].send(@order)}
          @out << "\n"
          player_list_header(2)
          player_stats.each do |player_stat|
            player_list_detail(player_stat[0], player_stat[1], 2)
          end
        end

      when Team
        team_header(@object, @stats)

      when Player
        player_header(@object)
      when BattingStat
        mlb_header
      else
        raise "Unknown Batting Stat type to format" 
    end
  end

  private

  def league_header(league, stats, indent=0)
    @out << sprintf("%s%s Batting\n", TAB * indent, league.name) 
    @out << sprintf("%sTotals   Teams: %d  Avg: %.3f  Slug: %.3f\n", TAB * (indent + 1), league.teams.count, stats.average, stats.slugging) 
  end

  def team_header(team, stats, indent=0)
    @out << sprintf("%s%s Batting\n", TAB * indent, team.name) 
    @out << sprintf("%sTotals   Avg: %.3f  Slug: %0.3f\n", TAB * (indent + 1),
                    stats.average, stats.slugging) 
  end

  def player_list_header(indent=0)
    @out << sprintf(PLAYER_HEADER_FORMAT, TAB * (indent + 1),
                    'Name',
                    'G',
                    'AB',
                    'H',
                    '2B',
                    '3B',
                    'HR',
                    'SB',
                    'CS',
                    'AVG',
                    'SLUG')
  end

  def player_list_detail(player, stats, indent=0)
    @out << sprintf(PLAYER_LINE_FORMAT, TAB * (indent + 1),
                    player.name,
                    stats.total_games,
                    stats.total_at_bats,
                    stats.total_hits,
                    stats.total_doubles,
                    stats.total_triples,
                    stats.total_home_runs,
                    stats.total_stolen_bases,
                    stats.total_caught_stealing,
                    sprintf("%.3f",stats.average).gsub(/^0+/, ''),
                    sprintf("%.3f",stats.slugging).gsub(/^0+/, ''))
  end
end
