class TripleCrownFormatter
  TAB="\t"
  HYPHEN="-"
  TITLE="Triple Crown Winner"
  LEADERS_GROUP_LEN=26
  LEADERS_HEADER_FORMAT=sprintf("%%-%ds  %%-%ds  %%-%ds\n", LEADERS_GROUP_LEN, LEADERS_GROUP_LEN, LEADERS_GROUP_LEN)
  LEADERS_GROUP_FORMAT="%-20.20s %5.5s"

  attr_writer :object, :stats
  attr_reader :out
  attr_accessor :restrict, :expand, :top

  def initialize(object, stats, options)
    @object   = object
    @stats    = stats
    @year     = options[:year]
    @restrict = options[:restrict]
    @expand   = options[:expand]
    @top      = options[:top]
    @indent   = options[:indent] || 0
    @out      = ""

    rbi_stats = RbiStats.new(stats: @stats)
    hr_stats = HomeRunStats.new(stats: @stats)
    avg_stats = AverageStats.new(stats: @stats)

    case @object
      when League
        league_header(@object, @stats)
        if avg_stats.eligible_stats.empty? or 
           hr_stats.eligible_stats.empty? or 
           rbi_stats.eligible_stats.empty?
          @out << TAB * (@indent+1) + "No Winner\n"
        end

        if avg_stats.winner.player == hr_stats.winner.player and
           hr_stats.winner.player == rbi_stats.winner.player
          @out << BattingStatFormatter.new(:average, avg_stats.winner.player, avg_stats.winner.stats, options.merge(indent: @indent + 1)).out
        else
          @out << TAB * (@indent+1) +  "No Winner\n"
        end unless avg_stats.eligible_stats.empty? or hr_stats.eligible_stats.empty? or rbi_stats.eligible_stats.empty?

        if @expand
          @out << "\n"
          leaders(hr_stats, rbi_stats, avg_stats)
          @object.teams.each do |team|
            stats = @stats.dup.where(team: team)
            stats.calculated_stats=nil
            
            @out << "\n\n"
            @out << TripleCrownFormatter.new(team, stats, options.merge(indent: @indent + 1)).out
          end
        end

      when Team
        team_header(@object, @stats)
        if avg_stats.eligible_stats.empty? or 
           hr_stats.eligible_stats.empty? or 
           rbi_stats.eligible_stats.empty?
          @out << TAB * (@indent+1) + "No Winner\n"
        end
        if avg_stats.winner.player == hr_stats.winner.player and
           hr_stats.winner.player == rbi_stats.winner.player
          @out << BattingStatFormatter.new(:average, avg_stats.winner.player, avg_stats.winner.stats, options.merge(indent: @indent + 1)).out
        else
          @out << TAB * (@indent+1) + "No Winner\n"
        end unless avg_stats.eligible_stats.empty? or hr_stats.eligible_stats.empty? or rbi_stats.eligible_stats.empty?

        if @expand
          @out << "\n"
          leaders(hr_stats, rbi_stats, avg_stats)
        end

      when BattingStat
        mlb_header(@stats)
        if avg_stats.winner.player == hr_stats.winner.player and
           hr_stats.winner.player == rbi_stats.winner.player
          @out << BattingStatFormatter.new(:average, avg_stats.winner.player, avg_stats.winner.stats, @year, @restrict).out
        else
          @out << "No Winner\n"
        end
        if @expand
          @out << "\n"
          leaders(hr_stats, rbi_stats, avg_stats)
          League.all.each do |league|
            stats = @stats.dup.where(league: league)
            stats.calculated_stats=nil
            
            @out << "\n\n\n"
            @out << TripleCrownFormatter.new(league, stats, options.merge(indent: @indent + 1)).out
          end
        end

      else
        raise "Unknown Triple Crown type to format" 
    end
  end

  private

  def leaders(hrs, rbis, avgs, indent=0)
    indent += @indent
    hr_leaders = hrs.top(0...@top)
    rbi_leaders = rbis.top(0...@top)
    avg_leaders = avgs.top(0...@top)
    @out << sprintf("%s" + LEADERS_HEADER_FORMAT, TAB * indent, "HR Leaders", "RBI Leaders", "AVG Leaders")
    @out << sprintf("%s" + LEADERS_HEADER_FORMAT, TAB * indent, HYPHEN * LEADERS_GROUP_LEN, HYPHEN * LEADERS_GROUP_LEN, HYPHEN * LEADERS_GROUP_LEN)
    @top.times do |i|
      break if hr_leaders[i].nil? and avg_leaders[i].nil? and rbi_leaders[i].nil?
      hr_player_name, total_home_runs = hr_leaders[i].nil?  ? ["", ""] : [hr_leaders[i].player.name, hr_leaders[i].stats.total_home_runs]

      rbi_player_name, total_rbi      = rbi_leaders[i].nil? ? ["", ""] : [rbi_leaders[i].player.name, rbi_leaders[i].stats.total_rbi]

      avg_player_name, average        = avg_leaders[i].nil? ? ["", ""] :
        [avg_leaders[i].player.name, avg_leaders[i].stats.average.nil? ? "NaN" : sprintf("%.3f",avg_leaders[i].stats.average).gsub(/^0+/, '')]

      @out << sprintf("%s" + ((LEADERS_GROUP_FORMAT + "  ") * 3).rstrip + "\n",  TAB * indent,
                      hr_player_name, total_home_runs,
                      rbi_player_name, total_rbi,
                      avg_player_name, average)
    end
  end

  def mlb_header(stats)
    @out << sprintf("%s MLB Triple Crown Winner\n", @year) 
  end


  def league_header(league, stats, indent=0)
    indent += @indent
    if indent == 0
      @out << sprintf("%s%s %s %s\n", TAB * indent, @year, league.name, TITLE) 
    else
      @out << sprintf("%s%s %s\n", TAB * indent, league.name, TITLE) 
    end  
  end

  def team_header(team, stats, indent=0)
    indent += @indent
    if indent == 0
      @out << sprintf("%s%s %s %s\n", TAB * indent, @year, team.name, TITLE) 
    else
      @out << sprintf("%s%s %s\n", TAB * indent, team.name, TITLE) 
    end
  end
end
