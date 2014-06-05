class MostImprovedStats < Stats
  property :prev_stats, required: true
  property :restrict, default: 200

  def initialize(*args)
    super
    self.player_stats.each do |a|
      a.prev_stats = prev_stats.dup.where(player: a.player)
      a.prev_stats.calculated_stats=nil
    end
    self.eligible_stats.reject!{|a| a.prev_stats.empty? or a.prev_stats.total_at_bats < (self.restrict.nil? ? 0 : self.restrict) }
  end

  def self.sort_field(field)
    super
    define_method('_sort') do
      @sorted ||= true
      self.eligible_stats.reject! {|a| a.stats.send(field).nil? or a.prev_stats.send(field).nil? }
      self.eligible_stats.sort! do |a,b|
        b_stat = b.stats.send(field).nil? ? 0 : b.stats.send(field)
        b_prev_stat = b.prev_stats.send(field).nil? ? 0 : b.prev_stats.send(field)
        a_stat = a.stats.send(field).nil? ? 0 : a.stats.send(field)
        a_prev_stat = a.prev_stats.send(field).nil? ? 0 : a.prev_stats.send(field)
        [(b_stat - b_prev_stat), a.player.name] <=> [(a_stat - a_prev_stat), b.player.name]
      end
    end

    alias_method :most_improved, :winner 

    define_method('prev_' + field.to_s) do
      self.prev_stats.send(field)
    end

    define_method(field.to_s + '_diff') do
      self.send(field) - self.send('prev_' + field.to_s)
    end
  end
end
