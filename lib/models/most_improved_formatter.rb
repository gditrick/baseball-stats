require_relative 'most_improved_home_runs'
require_relative 'most_improved_rbi'
require_relative 'most_improved_runs'
require_relative 'most_improved_slugging'

class MostImprovedFormatter
  TAB="\t"
  HYPHEN="-"
  TITLE="Most Improved Player"
  STAT_METHODS={
    avg: :average,
    hr: :total_home_runs,
    rbi: :total_rbi,
    runs: :total_runs,
    slug: :slugging
  }
  STAT_KLASSES={
    avg: MostImprovedAverage,
    hr: MostImprovedHomeRuns,
    rbi: MostImprovedRbi,
    runs: MostImprovedRuns,
    slug: MostImprovedSlugging
  }

  attr_writer :object, :stat_type, :stats, :prev_stats
  attr_reader :out
  attr_accessor :restrict

  def initialize(object, stat_type, stats, prev_stats, options)
    @object     = object
    @stat_type  = stat_type.to_sym
    @stats      = stats
    @prev_stats = prev_stats
    @year       = options[:year]
    @restrict   = options[:restrict]
    @expand     = options[:expand]
    @top        = options[:top]
    @indent     = options[:indent] || 0
    @out        = ""

    
    raise "Unknown Most Improved statistic to find" if STAT_KLASSES[@stat_type].nil?
    stats = STAT_KLASSES[@stat_type].new(stats: @stats, prev_stats: @prev_stats, restrict: @restrict)

    case @object
      when League
        league_header(@object)
        if stats.eligible_stats.empty? or
           prev_stats.empty?
          @out << sprintf("%s%s\n", TAB * @indent, "No Winner")
        else
          @out << BattingStatFormatter.new(:average, stats.most_improved.player, stats.most_improved.prev_stats, options.merge(indent: @indent + 1)).out
          @out << BattingStatFormatter.new(:average, stats.most_improved.player, stats.most_improved.stats, options.merge(indent: @indent + 1, no_headers: true)).out
          if @expand
            @out << "\n"
            leaders(stats)
            @object.teams.each do |team|
              stats = @stats.dup.where(team: team)
              stats.calculated_stats=nil
            
              @out << "\n\n"
              @out << MostImprovedFormatter.new(team, @stat_type, stats, @prev_stats, options.merge(indent: @indent + 1)).out
            end
          end
        end

      when Team
        team_header(@object)
        if stats.eligible_stats.empty? or
           prev_stats.empty?
          @out << sprintf("%s%s\n", TAB * @indent, "No Winner")
        else
          @out << BattingStatFormatter.new(:average, stats.most_improved.player, stats.most_improved.prev_stats, options.merge(indent: @indent + 1)).out
          @out << BattingStatFormatter.new(:average, stats.most_improved.player, stats.most_improved.stats, options.merge(indent: @indent + 1, no_headers: true)).out
          if @expand
            @out << "\n"
            leaders(stats)
          end
        end

      when BattingStat
        mlb_header
        if stats.eligible_stats.empty? or
           prev_stats.empty?
          @out << sprintf("%s%s\n", TAB * @indent, "No Winner")
        else
          @out << BattingStatFormatter.new(:average, stats.most_improved.player, stats.most_improved.prev_stats, options.merge(indent: @indent + 1)).out
          @out << BattingStatFormatter.new(:average, stats.most_improved.player, stats.most_improved.stats, options.merge(indent: @indent + 1, no_headers: true)).out
          if @expand
            @out << "\n"
            leaders(stats)
            League.order(:id).each do |league|
              stats = @stats.dup.where(league: league)
              stats.calculated_stats=nil
            
              @out << "\n\n\n"
              @out << MostImprovedFormatter.new(league, @stat_type, stats, @prev_stats, options.merge(indent: @indent + 1)).out
            end
          end
        end
      else
        raise "Unknown Most Improved stat type to format" 
    end
  end

  private

  def leaders(stats, indent=0)
    indent += @indent
    leaders = stats.top(0...@top)
    @out << sprintf("%s%s Most Improved Leaders\n",  TAB * indent, @stat_type.upcase) 
    @out << sprintf("%s%-20.20s  %5.5s  %5.5s  %5.5s\n",  TAB * indent,
                    "", @year.to_i - 1, @year, "Diff")
    @top.times do |i|
      break if leaders[i].nil?
      prev_stat = leaders[i].prev_stats.send(STAT_METHODS[@stat_type]).nil? ? 0 : leaders[i].prev_stats.send(STAT_METHODS[@stat_type])
      stat = leaders[i].stats.send(STAT_METHODS[@stat_type]).nil? ? 0 : leaders[i].stats.send(STAT_METHODS[@stat_type])
      diff = stat - prev_stat
      if @stat_type == :avg or @stat_type == :slug
         prev_stat  = prev_stat.nil? ? "NaN" : sprintf("%.3f",prev_stat).gsub(/^0+/, '')
         stat       = stat.nil? ? "NaN" : sprintf("%.3f",stat).gsub(/^0+/, '')
         diff       = diff.nil? ? "NaN" : sprintf("%.3f",diff).gsub(/^0+/, '').gsub(/^-0+/, '-')
      end
      @out << sprintf("%s%-20.20s  %5.5s  %5.5s  %5.5s\n",  TAB * indent,
                      leaders[i].player.name, prev_stat, stat, diff) 
    end
  end

  def mlb_header
    @out << sprintf("%s MLB %s %s\n", @year, TITLE, @stat_type.upcase) 
  end


  def league_header(league, indent=0)
    indent += @indent
    if indent == 0
      @out << sprintf("%s%s %s %s %s\n", TAB * indent, @year, league.name, TITLE, @stat_type.upcase) 
    else
      @out << sprintf("%s%s %s %s\n", TAB * indent, league.name, TITLE, @stat_type.upcase) 
    end  
  end

  def team_header(team, indent=0)
    indent += @indent
    if indent == 0
      @out << sprintf("%s%s %s %s %s\n", TAB * indent, @year, team.name, TITLE, @stat_type.upcase) 
    else
      @out << sprintf("%s%s %s %s\n", TAB * indent, team.name, TITLE, @stat_type.upcase) 
    end
  end
end
