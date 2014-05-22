class BattingStatFormatter
  TAB="\t"
  STATS_HEADER_FORMAT="%4s %5s %4s %4s %3s %3s %3s %4s %4s %3s %5s %5s\n"
  STATS_LINE_FORMAT  ="%4d %5d %4d %4d %3d %3d %3d %4d %4d %3d %5s %5s\n"
  PLAYER_HEADER_FORMAT="%-30s " + STATS_HEADER_FORMAT
  PLAYER_LINE_FORMAT=  "%-30s " + STATS_LINE_FORMAT

  attr_writer :order, :object, :stats
  attr_reader :out
  attr_accessor :restrict

  def initialize(order, object, stats, year, restrict=nil)
    @order    = order
    @object   = object
    @stats    = stats
    @year     = year
    @restrict = restrict
    @out      = ""

    case @object
      when League
        league_header(@object, @stats)

        team_stats = @object.teams.map{|a| stats = @stats.dup.where(team: a); stats.calculated_stats=nil; [a, stats]}
        team_stats.reject!{|a| a[1].empty?}
        team_stats.sort!{|a,b| b[1].send(@order) <=> a[1].send(@order)}

        team_stats.each do |team_stat|
          @out << "\n"
          team_header(team_stat[0], team_stat[1], 1)
          players = team_stat[1].map(&:player).uniq
          player_stats = players.map{|a| stats = team_stat[1].dup.where(player: a); stats.calculated_stats=nil; [a, stats]}
          player_stats.reject!{|a| a[1].empty? or a[1].total_at_bats < (@restrict.nil? ? 0 : @restrict) }
          player_stats.sort! do |a,b|
            a = a[1].send(@order).nil? ? -1.0: a[1].send(@order)
            b = b[1].send(@order).nil? ? -1.0: b[1].send(@order)
            b <=> a
          end
          @out << "\n"
          player_list_header(2)
          player_stats.each do |player_stat|
            player_list_detail(player_stat[0], player_stat[1], 2)
          end
        end

      when Team
        team_header(@object, @stats)
        players = @stats.map(&:player).uniq
        player_stats = players.map{|a| stats = @stats.dup.where(player: a); stats.calculated_stats=nil; [a, stats]}
        player_stats.reject!{|a| a[1].empty? or a[1].total_at_bats < (@restrict.nil? ? 0 : @restrict) }
        player_stats.sort! do |a,b|
          a = a[1].send(@order).nil? ? -1.0: a[1].send(@order)
          b = b[1].send(@order).nil? ? -1.0: b[1].send(@order)
          b <=> a
        end
        @out << "\n"
        player_list_header(2)
        player_stats.each do |player_stat|
          player_list_detail(player_stat[0], player_stat[1], 2)
        end

      when Player
        player_header(@object, @stats)
        years = @stats.map(&:year).uniq.sort
        @out << "\n"
        @out << sprintf("%s%-4s %-4s" + STATS_HEADER_FORMAT, TAB,
                        'Year',
                        'Team',
                        'G',
                        'AB',
                        'R',
                        'H',
                        '2B',
                        '3B',
                        'HR',
                        'RBI',
                        'SB',
                        'CS',
                        'AVG',
                        'SLUG')
        years.each do |year|
          year_stats = @stats.dup.where(year: year)
          year_stats.calculated_stats=nil
          teams = year_stats.map(&:team).uniq.sort_by(&:id)
          teams_stats = teams.map{|a| stats = year_stats.dup.where(team: a); stats.calculated_stats=nil; [a, stats]}
          teams_stats.each do |player_team_stat|
            average  = player_team_stat[1].average.nil? ? "NaN" : sprintf("%.3f",player_team_stat[1].average).gsub(/^0+/, '')
            slugging = player_team_stat[1].slugging.nil? ? "NaN" : sprintf("%.3f",player_team_stat[1].slugging).gsub(/^0+/, '')
            @out << sprintf("%s%-4s %-4s" + STATS_LINE_FORMAT, TAB,
                        year,
                        player_team_stat[0].id,
                        player_team_stat[1].total_games,
                        player_team_stat[1].total_at_bats,
                        player_team_stat[1].total_runs,
                        player_team_stat[1].total_hits,
                        player_team_stat[1].total_doubles,
                        player_team_stat[1].total_triples,
                        player_team_stat[1].total_home_runs,
                        player_team_stat[1].total_rbi,
                        player_team_stat[1].total_stolen_bases,
                        player_team_stat[1].total_caught_stealing,
                        average,
                        slugging)
          end
        end

      when BattingStat
        mlb_header(@stats)
        League.order(:id).each do |league|
          league_stats = @stats.dup.where(league: league)
          league_stats.calculated_stats=nil
          
          @out << "\n"

          league_header(league, league_stats, 1)

          team_stats = league.teams.map{|a| stats = league_stats.dup.where(team: a); stats.calculated_stats=nil; [a, stats]}
          team_stats.reject!{|a| a[1].empty?}
          team_stats.sort!{|a,b| b[1].send(@order) <=> a[1].send(@order)}
          team_stats.each do |team_stat|
            @out << "\n"
            team_header(team_stat[0], team_stat[1], 2)
            players = team_stat[1].map(&:player).uniq
            player_stats = players.map{|a| stats = team_stat[1].dup.where(player: a); stats.calculated_stats=nil; [a, stats]}
            player_stats.reject!{|a| a[1].empty? or a[1].total_at_bats < (@restrict.nil? ? 0 : @restrict) }
            player_stats.sort! do |a,b|
              a = a[1].send(@order).nil? ? -1.0: a[1].send(@order)
              b = b[1].send(@order).nil? ? -1.0: b[1].send(@order)
              b <=> a
            end
            @out << "\n"
            player_list_header(3)
            player_stats.each do |player_stat|
              player_list_detail(player_stat[0], player_stat[1], 3)
            end
          end
        end
      else
        raise "Unknown Batting Stat type to format" 
    end
  end

  private

  def player_header(player, stats, indent=0)
    average  = stats.average.nil? ? "NaN" : sprintf("%.3f",stats.average).gsub(/^0+/, '')
    slugging = stats.slugging.nil? ? "NaN" : sprintf("%.3f",stats.slugging).gsub(/^0+/, '')
    @out << sprintf("%s %s\n", player.first_name, player.last_name) 
    @out << sprintf("Birth Year: %s\n", player.birth_year) 
    if @year.nil?
      @out << "\n"
      @out << sprintf("%sCareer Stats\n", TAB * (indent + 1))
      @out << sprintf("%s" + STATS_HEADER_FORMAT, TAB * (indent + 1),
                    'G',
                    'AB',
                    'R',
                    'H',
                    '2B',
                    '3B',
                    'HR',
                    'RBI',
                    'SB',
                    'CS',
                    'AVG',
                    'SLUG')
      average  = stats.average.nil? ? "NaN" : sprintf("%.3f",stats.average).gsub(/^0+/, '')
      slugging = stats.slugging.nil? ? "NaN" : sprintf("%.3f",stats.slugging).gsub(/^0+/, '')
      @out << sprintf("%s" + STATS_LINE_FORMAT, TAB * (indent + 1),
                      stats.total_games,
                      stats.total_at_bats,
                      stats.total_runs,
                      stats.total_hits,
                      stats.total_doubles,
                      stats.total_triples,
                      stats.total_home_runs,
                      stats.total_rbi,
                      stats.total_stolen_bases,
                      stats.total_caught_stealing,
                      average,
                      slugging)
    end
  end

  def mlb_header(stats)
    average  = stats.average.nil? ? "NaN" : sprintf("%.3f",stats.average).gsub(/^0+/, '')
    slugging = stats.slugging.nil? ? "NaN" : sprintf("%.3f",stats.slugging).gsub(/^0+/, '')
    @out << sprintf("%s MLB Batting\n", @year) 
  end


  def league_header(league, stats, indent=0)
    average  = stats.average.nil? ? "NaN" : sprintf("%.3f",stats.average).gsub(/^0+/, '')
    slugging = stats.slugging.nil? ? "NaN" : sprintf("%.3f",stats.slugging).gsub(/^0+/, '')
    if indent == 0
      @out << sprintf("%s%s %s Batting\n", TAB * indent, @year, league.name) 
    else
      @out << sprintf("%s%s Batting\n", TAB * indent, league.name) 
    end
    @out << sprintf("%sTotals   Teams: %d  Avg: %s  Slug: %s\n", TAB * (indent + 1), league.teams.count, average, slugging) 
  end

  def team_header(team, stats, indent=0)
    average  = stats.average.nil? ? "NaN" : sprintf("%.3f",stats.average).gsub(/^0+/, '')
    slugging = stats.slugging.nil? ? "NaN" : sprintf("%.3f",stats.slugging).gsub(/^0+/, '')
    if indent == 0
      @out << sprintf("%s%s %s Batting\n", TAB * indent, @year, team.name) 
    else
      @out << sprintf("%s%s Batting\n", TAB * indent, team.name) 
    end
    @out << sprintf("%sTotals   Avg: %s  Slug: %s\n", TAB * (indent + 1), average, slugging) 
  end

  def player_list_header(indent=0)
    @out << sprintf(PLAYER_HEADER_FORMAT, TAB * (indent + 1),
                    'Name',
                    'G',
                    'AB',
                    'R',
                    'H',
                    '2B',
                    '3B',
                    'HR',
                    'RBI',
                    'SB',
                    'CS',
                    'AVG',
                    'SLUG')
  end

  def player_list_detail(player, stats, indent=0)
    average  = stats.average.nil? ? "NaN" : sprintf("%.3f",stats.average).gsub(/^0+/, '')
    slugging = stats.slugging.nil? ? "NaN" : sprintf("%.3f",stats.slugging).gsub(/^0+/, '')
    @out << sprintf(PLAYER_LINE_FORMAT, TAB * (indent + 1),
                    player.name,
                    stats.total_games,
                    stats.total_at_bats,
                    stats.total_runs,
                    stats.total_hits,
                    stats.total_doubles,
                    stats.total_triples,
                    stats.total_home_runs,
                    stats.total_rbi,
                    stats.total_stolen_bases,
                    stats.total_caught_stealing,
                    average,
                    slugging)
  end
end
