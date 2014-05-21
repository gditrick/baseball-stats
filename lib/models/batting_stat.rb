class BattingStat < Sequel::Model
  plugin :timestamps

  many_to_one :player
  many_to_one :team
  many_to_one :league

  dataset_module do
    attr_accessor :calculated_stats

    def average
      calculate_totals
      (calculated_stats[:hits].to_f / calculated_stats[:at_bats].to_f).round(3) unless calculated_stats[:at_bats] == 0
    end
    def slugging
      calculate_totals
      ab = calculated_stats[:at_bats]
      h = calculated_stats[:hits]
      d = calculated_stats[:doubles]
      t = calculated_stats[:triples]
      hr = calculated_stats[:home_runs]
      (((h - d - t - hr) + (2 * d + 3 * t + 4 * hr)).to_f / ab.to_f).round(3) unless ab == 0
    end
    def total_at_bats
      calculate_totals
      calculated_stats[:at_bats]
    end
    def total_caught_stealing
      calculate_totals
      calculated_stats[:caught_stealing]
    end
    def total_stolen_bases
      calculate_totals
      calculated_stats[:stolen_bases]
    end
    def total_doubles
      calculate_totals
      calculated_stats[:doubles]
    end
    def total_games
      calculate_totals
      calculated_stats[:games]
    end
    def total_hits
      calculate_totals
      calculated_stats[:hits]
    end
    def total_home_runs
      calculate_totals
      calculated_stats[:home_runs]
    end
    def total_rbi
      calculate_totals
      calculated_stats[:rbi]
    end
    def total_runs
      calculate_totals
      calculated_stats[:runs]
    end
    def total_triples
      calculate_totals
      calculated_stats[:triples]
    end

    private

    def calculate_totals
      @calculated_stats ||= self.inject({}) do |m,o|
        o.values.inject(m) do |a,(k,v)|
          if v.is_a?(Fixnum)
            a[k] ||= 0
            a[k] += v unless v.nil?
          end
          m
        end
      end
    end
  end

  def_dataset_method(:for_year) do |year|
    where(year: year).default_order
  end

  def_dataset_method(:for_team) do |team|
    where(team_id: team).default_order
  end

  def_dataset_method(:for_league) do |league|
    where(league_id: league).default_order
  end

  def_dataset_method(:for_player) do |player|
    where(player: player).default_order
  end

  def_dataset_method(:default_order) do
    order(:year, :league_id, :team_id, :player_id)
  end
end
