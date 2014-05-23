class TripleCrown
  attr_accessor :stats, :rbi_stats

  def initialize(stats, restrict=400)
    @stats    = stats

    players = stats.map(&:player).uniq
    player_stats = players.map{|a| stats = stats.dup.where(player: a); stats.calculated_stats=nil; [a, stats]}
    player_stats.reject!{|a| a[1].empty? or a[1].total_at_bats < (@restrict.nil? ? 0 : @restrict) }
  end
end
