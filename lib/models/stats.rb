require_relative 'batting_stat'

class Stats < Hashie::Dash
  property :stats, required: true
  property :restrict, default: 400
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
      player_stat
    end
    self.eligible_stats=self.player_stats.reject{|a| a.stats.empty? or a.stats.total_at_bats < (self.restrict.nil? ? 0 : self.restrict) }
  end

  def self.sort_field(field)
    raise "Undefined method <#{field}> for BattingStat" unless BattingStat.instance_dataset.respond_to?(field) or
                                                               BattingStat.new.respond_to?(field)
    define_method('_sort') do
      @sorted ||= true
      self.eligible_stats.sort!{|a,b| b.stats.send(field) <=> a.stats.send(field) }
    end

    define_method(:winner) do
      @sorted ||= false
      self._sort unless @sorted
      self.eligible_stats.first
    end

    define_method(:top) do |c|
      @sorted ||= false
      self._sort unless @sorted
      self.eligible_stats.slice(c)
    end

    define_method(field) do
      self.stats.send(field)
    end
  end
end
