class MostImprovedStats < Hashie::Dash
  property :stats, required: true
  property :prev_stats, required: true
  property :restrict, default: 200
  property :players
  property :player_stats
  property :eligible_stats

  def initialize(*args)
    super
    self.players = self.stats.map(&:player).uniq
    self.player_stats = self.players.map do |a|
      player_stat = Hashie::Mash.new
      player_stat.player = a
      player_stat.stats = stats.dup.where(player: a)
      player_stat.stats.calculated_stats=nil
      player_stat.prev_stats = prev_stats.dup.where(player: a)
      player_stat.prev_stats.calculated_stats=nil
      player_stat
    end
    self.eligible_stats=self.player_stats.reject{|a| a.stats.empty? or a.stats.total_at_bats < (self.restrict.nil? ? 0 : self.restrict) or
                                                     a.prev_stats.empty? or a.prev_stats.total_at_bats < (self.restrict.nil? ? 0 : self.restrict) }
  end

  def self.sort_field(field)
    raise "BattingStat does not have a method #{field}" unless BattingStat.instance_dataset.respond_to?(field)
    define_method('_sort') do
      @sorted ||= true
      self.eligible_stats.sort! do |a,b|
        b_stat = b.stats.send(field).nil? ? 0 : b.stats.send(field)
        b_prev_stat = b.prev_stats.send(field).nil? ? 0 : b.prev_stats.send(field)
        a_stat = a.stats.send(field).nil? ? 0 : a.stats.send(field)
        a_prev_stat = a.prev_stats.send(field).nil? ? 0 : a.prev_stats.send(field)
        (b_stat - b_prev_stat) <=> (a_stat - a_prev_stat)
      end
    end

    define_method(:most_improved) do
      @sorted ||= false
      self._sort unless @sorted
      self.eligible_stats.first
    end

    define_method(:top) do |c|
      @sorted ||= false
      self._sort unless @sorted
      self.eligible_stats.slice(c)
    end
  end
end
