require File.join(File.dirname(File.expand_path(__FILE__)), "../spec_helper")
require 'pp'
require 'shellwords'
VALID_OBJECTS= [BattingStat, League, Team, Player]
OBJECT_HEADER_ATTRS={
  BattingStat => { hardcoded_values: ["MLB"],
                   attrs: []
  },
  League => { hardcoded_values: [],
              attrs: %i(name)
  },
  Team => { hardcoded_values: [],
            attrs: %i(name)
  },
  Player => { hardcoded_values: %w(Year Team AB G R H 2B 3B HR RBI AVG SLUG),
              attrs: %i(first_name last_name birth_year)
  }
}

describe BattingStatFormatter do
  context ".new" do
    When(:instance) { BattingStatFormatter.new(:average, BattingStat.new, BattingStat.default_order, year: '2011') }
    Then { instance.should respond_to(:out) }
    Then { instance.should respond_to(:restrict) }
  end

  describe "Player with empty stats with no year" do
    context "#out" do
      Given(:stats) { BattingStat.default_order }
      BattingStatFormatter::ALLOWED_ORDERS.each do |order|
        describe "ordered by #{order}" do
          Given(:object_instance) { build_stubbed(:player) }
          Given(:formatter) { BattingStatFormatter.new(order, object_instance, stats, {}) }
          Then { expect{formatter}.not_to raise_error }
          When(:out) { formatter.out }
          Then { out.should_not be_empty }
          Then { out.should include("Career") }
        end
      end
    end
  end

  describe "with empty stats" do
    context "#out" do
      Given(:stats) { BattingStat.default_order }
      describe "invalid order by" do
        Given(:formatter) { BattingStatFormatter.new(:invalid_order, BattingStat.new, stats, year: '2011') }
        Then { expect{formatter}.to raise_error }
      end
      describe "invalid starting object" do
        Given(:formatter) { BattingStatFormatter.new(:average, Stats.new(stats: stats), stats, year: '2011') }
        Then { expect{formatter}.to raise_error }
      end
      BattingStatFormatter::ALLOWED_ORDERS.each do |order|
        describe "ordered by #{order}" do
          VALID_OBJECTS.each do |object|
            describe "with starting object of #{object}" do
              Given(:object_instance) { build_stubbed(object) }
              Given(:formatter) { BattingStatFormatter.new(order, object_instance, stats, year: '2011') }
              Then { expect{formatter}.not_to raise_error }
              When(:out) { formatter.out }
              Then { out.should_not be_empty }
              Then { out.should include("2011") } unless object == Player
              Then { out.should include("Batting") }
              OBJECT_HEADER_ATTRS[object][:hardcoded_values].each do |val|
                Then { out.should match(/[[:space:]]*#{val}*[[:space:]]/) }
              end
              OBJECT_HEADER_ATTRS[object][:attrs].each do |attr|
                Then { out.should include(object_instance.send(attr)) }
              end
            end
          end
        end
      end
    end
  end
  describe "with basic stats" do
    before(:all) do
      create_basic_data(BattingStatFormatter.to_s, '2011')
    end
    after(:all) do
      BattingStat.dataset.delete
      Team.dataset.delete
      League.dataset.delete
      Player.dataset.delete
    end

    basic_givens(BattingStatFormatter.to_s)

    Given(:stats) { BattingStat.for_year('2011') }
    VALID_OBJECTS.each_with_index do |object, ob_idx|

      describe "for a(n) #{object}" do

        Given(:object_instance) { object.all.sample }
        case object.new
        when League then
          Given(:obj_stats) { stats.for_league(object_instance) }
        when Team then
          Given(:obj_stats) { stats.for_team(object_instance) }
        when Player then
          Given(:obj_stats) { stats.for_player(object_instance) }
        else
          Given(:object_instance) { object.new }
          Given(:obj_stats) { stats }
        end

        BattingStatFormatter::ALLOWED_ORDERS.each_with_index do |order, or_idx|

          describe "ordered by #{order}" do
            context "#out" do

              Given(:formatter) { BattingStatFormatter.new(order, object_instance, obj_stats, {year: '2011', restrict: 200}) }
              Then { expect{formatter}.not_to raise_error }

              When(:out) { formatter.out }
              Then { out.should_not be_empty }
              Then { out.should include("2011") } unless object == Player
              Then { out.should include("Batting") }
              OBJECT_HEADER_ATTRS[object][:hardcoded_values].each do |val|
                Then { out.should match(/[[:space:]]*#{val}*[[:space:]]/) }
              end
              OBJECT_HEADER_ATTRS[object][:attrs].each do |attr|
                Then { out.should include(object_instance.send(attr)) }
              end

              unless object == Player

                When(:out_players) { split_out_players(out) }
                Then { out_players.should be_empty }

                Given(:no_restrict_formatter) { BattingStatFormatter.new(order, object_instance, obj_stats, {year: '2011', restrict: nil}) }
                Then { expect{no_restrict_formatter}.not_to raise_error }

                When(:no_restrict_out) { no_restrict_formatter.out }
                Then { no_restrict_out.should_not be_empty }
                Then { no_restrict_out.should include("2011") }
                Then { no_restrict_out.should include("Batting") }

                When(:no_restrict_out_players) { split_out_players(no_restrict_out) }
                Then { no_restrict_out_players.should_not be_empty }

                player_order = [:hits, :doubles, :triples, :home_runs] if [:total_at_bats, :total_hits, :average, :slugging].include?(order)
                player_order.reverse! if order == :slugging
                player_order << :at_bats if [:average, :slugging].include?(order)
                player_order.unshift(:at_bats) if order == :total_at_bats
                player_order = order.to_s.gsub(/^total_/,'').to_sym unless [:total_at_bats, :total_hits, :average, :slugging].include?(order)

                case object.new
                when BattingStat then
                  if [:average, :slugging].include?(order)
                    Given(:al_player_names_in_order) do
                      player_order.inject([]) do |m,o|
                        BASIC_DATA_PLAYERS_COUNT.times.inject(m) do |a,i|
                          a << send(make_player_given_id('', 'AL', (BATTING_STAT_ATTRS.index(o) * BASIC_DATA_PLAYERS_COUNT + i + 1))).name[0...22]
                        end
                      end
                    end
                    Given(:nl_player_names_in_order) do
                      player_order.inject([]) do |m,o|
                        BASIC_DATA_PLAYERS_COUNT.times.inject(m) do |a,i|
                          a << send(make_player_given_id('', 'NL', (BATTING_STAT_ATTRS.index(o) * BASIC_DATA_PLAYERS_COUNT + i + 1))).name[0...22]
                        end
                      end
                    end
                  elsif [:total_at_bats, :total_hits].include?(order)
                    Given(:al_players) do
                      player_order.inject([]) do |m,o|
                        BASIC_DATA_PLAYERS_COUNT.times.inject(m) do |a,i|
                          a << send(make_player_given_id('', 'AL', (BATTING_STAT_ATTRS.index(o) * BASIC_DATA_PLAYERS_COUNT + i + 1)))
                        end
                      end
                    end
                    Given(:nl_players) do
                      player_order.inject([]) do |m,o|
                        BASIC_DATA_PLAYERS_COUNT.times.inject(m) do |a,i|
                          a << send(make_player_given_id('', 'NL', (BATTING_STAT_ATTRS.index(o) * BASIC_DATA_PLAYERS_COUNT + i + 1)))
                        end
                      end
                    end
                    Given(:al_player_names_in_order) do
                      (al_players + (basic_stats_al_players - al_players)).map{|a| a.name[0...22] }
                    end
                    Given(:nl_player_names_in_order) do
                      (nl_players + (basic_stats_nl_players - nl_players)).map{|a| a.name[0...22] }
                    end
                  else
                    Given(:al_players) do
                      BASIC_DATA_PLAYERS_COUNT.times.inject([]) do |a,i|
                        a << send(make_player_given_id('', 'AL', (BATTING_STAT_ATTRS.index(player_order) * BASIC_DATA_PLAYERS_COUNT + i + 1)))
                      end
                    end
                    Given(:nl_players) do
                      BASIC_DATA_PLAYERS_COUNT.times.inject([]) do |a,i|
                        a << send(make_player_given_id('', 'NL', (BATTING_STAT_ATTRS.index(player_order) * BASIC_DATA_PLAYERS_COUNT + i + 1)))
                      end
                    end
                    Given(:al_player_names_in_order) do
                      (al_players + (basic_stats_al_players - al_players)).map{|a| a.name[0...22] }
                    end
                    Given(:nl_player_names_in_order) do
                      (nl_players + (basic_stats_nl_players - nl_players)).map{|a| a.name[0...22] }
                    end
                  end
                  Given(:player_names_in_order) { al_player_names_in_order + nl_player_names_in_order }
                when League then
                  if [:average, :slugging].include?(order)
                    Given(:player_names_in_order) do
                      player_order.inject([]) do |m,o|
                        BASIC_DATA_PLAYERS_COUNT.times.inject(m) do |a,i|
                          a << send(make_player_given_id('', object_instance.id,
                                                         (BATTING_STAT_ATTRS.index(o) * BASIC_DATA_PLAYERS_COUNT + i + 1))).name[0...22]
                        end
                      end
                    end
                  elsif [:total_at_bats, :total_hits].include?(order)
                    Given(:players) do
                      player_order.inject([]) do |m,o|
                        BASIC_DATA_PLAYERS_COUNT.times.inject(m) do |a,i|
                          a << send(make_player_given_id('', object_instance.id, (BATTING_STAT_ATTRS.index(o) * BASIC_DATA_PLAYERS_COUNT + i + 1)))
                        end
                      end
                    end
                    Given(:player_names_in_order) do
                      (players + (send('basic_stats_' + object_instance.id.downcase + '_players') - players)).map{|a| a.name[0...22] }
                    end
                  else
                    Given(:players) do
                      BASIC_DATA_PLAYERS_COUNT.times.inject([]) do |a,i|
                        a << send(make_player_given_id('', object_instance.id,
                                                       (BATTING_STAT_ATTRS.index(player_order) * BASIC_DATA_PLAYERS_COUNT + i + 1)))
                      end
                    end
                    Given(:player_names_in_order) do
                      (players + (send('basic_stats_' + object_instance.id.downcase + '_players') - players)).map{|a| a.name[0...22] }
                    end
                  end
                when Team then
                  Given(:player_names_in_order) do
                    BASIC_DATA_PLAYERS_COUNT.times.inject([]) do |a,i|
                      a << send(make_player_given_id('', object_instance.league.id,
                                                     (object_instance.league.teams.index(object_instance) * BASIC_DATA_PLAYERS_COUNT + i + 1))).name[0...22]
                    end
                  end
                end

                Then { no_restrict_out_players.map{|a| a[:name]}.should == player_names_in_order }
              end
            end
          end
        end
      end
    end
  end

=begin
  describe "with set of stats" do
    before(:all) do
      create_basic_data(BattingStatFormatter.to_s, '2011')
    end
    after(:all) do
      BattingStat.dataset.delete
      Team.dataset.delete
      League.dataset.delete
      Player.dataset.delete
    end

    basic_givens(BattingStatFormatter.to_s)

    Given(:stats) { BattingStat.for_year('2011') }
    VALID_OBJECTS.each_with_index do |object, ob_idx|

      describe "for a(n) #{object}" do

        Given(:object_instance) { object.all.sample }
        case object.new
        when League then
          Given(:obj_stats) { stats.for_league(object_instance) }
        when Team then
          Given(:obj_stats) { stats.for_team(object_instance) }
        when Player then
          Given(:obj_stats) { stats.for_player(object_instance) }
        else
          Given(:object_instance) { object.new }
          Given(:obj_stats) { stats }
        end

        BattingStatFormatter::ALLOWED_ORDERS.each_with_index do |order, or_idx|

          describe "ordered by #{order}" do
            context "#out" do

              Given(:formatter) { BattingStatFormatter.new(order, object_instance, obj_stats, {year: '2011', restrict: 200}) }
              Then { expect{formatter}.not_to raise_error }

              When(:out) { formatter.out }
              Then { out.should_not be_empty }
              Then { out.should include("2011") } unless object == Player
              Then { out.should include("Batting") }
              OBJECT_HEADER_ATTRS[object][:hardcoded_values].each do |val|
                Then { out.should match(/[[:space:]]*#{val}*[[:space:]]/) }
              end
              OBJECT_HEADER_ATTRS[object][:attrs].each do |attr|
                Then { out.should include(object_instance.send(attr)) }
              end

              unless object == Player

                When(:out_players) { split_out_players(out) }
                Then { out_players.should be_empty }

                Given(:no_restrict_formatter) { BattingStatFormatter.new(order, object_instance, obj_stats, {year: '2011', restrict: nil}) }
                Then { expect{no_restrict_formatter}.not_to raise_error }

                When(:no_restrict_out) { no_restrict_formatter.out }
                Then { no_restrict_out.should_not be_empty }
                Then { no_restrict_out.should include("2011") }
                Then { no_restrict_out.should include("Batting") }

                When(:no_restrict_out_players) { split_out_players(no_restrict_out) }
                Then { no_restrict_out_players.should_not be_empty }

                player_order = [:hits, :doubles, :triples, :home_runs] if [:total_at_bats, :total_hits, :average, :slugging].include?(order)
                player_order.reverse! if order == :slugging
                player_order << :at_bats if [:average, :slugging].include?(order)
                player_order.unshift(:at_bats) if order == :total_at_bats
                player_order = order.to_s.gsub(/^total_/,'').to_sym unless [:total_at_bats, :total_hits, :average, :slugging].include?(order)

                case object.new
                when BattingStat then
                  if [:average, :slugging].include?(order)
                    Given(:al_player_names_in_order) do
                      player_order.inject([]) do |m,o|
                        m << send(make_player_given_id('', 'AL', (BATTING_STAT_ATTRS.index(o) + 1))).name[0...22]
                      end
                    end
                    Given(:nl_player_names_in_order) do
                      player_order.inject([]) do |m,o|
                        m << send(make_player_given_id('', 'NL', (BATTING_STAT_ATTRS.index(o) + 1))).name[0...22]
                      end
                    end
                  elsif [:total_at_bats, :total_hits].include?(order)
                    Given(:al_players) do
                      player_order.inject([]) do |m,o|
                        m << send(make_player_given_id('', 'AL', (BATTING_STAT_ATTRS.index(o) + 1)))
                      end
                    end
                    Given(:al_player_names_in_order) do
                      (al_players + (basic_stats_al_players - al_players)).map{|a| a.name[0...22] }
                    end
                    Given(:nl_players) do
                      player_order.inject([]) do |m,o|
                        m << send(make_player_given_id('', 'NL', (BATTING_STAT_ATTRS.index(o) + 1)))
                      end
                    end
                    Given(:nl_player_names_in_order) do
                      (nl_players + (basic_stats_nl_players - nl_players)).map{|a| a.name[0...22] }
                    end
                  else
                    Given(:al_player_names_in_order) do
                      ([send(make_player_given_id('', 'AL', (BATTING_STAT_ATTRS.index(player_order) + 1)))] +
                      (basic_stats_al_players - [send(make_player_given_id('', 'AL', (BATTING_STAT_ATTRS.index(player_order) + 1)))])).
                        map{|a| a.name[0...22] }
                    end
                    Given(:nl_player_names_in_order) do
                      ([send(make_player_given_id('', 'NL', (BATTING_STAT_ATTRS.index(player_order) + 1)))] +
                      (basic_stats_nl_players - [send(make_player_given_id('', 'NL', (BATTING_STAT_ATTRS.index(player_order) + 1)))])).
                        map{|a| a.name[0...22] }
                    end
                  end
                  Given(:player_names_in_order) { al_player_names_in_order + nl_player_names_in_order }
                when League then
                  if [:average, :slugging].include?(order)
                    Given(:player_names_in_order) do
                      player_order.inject([]) do |m,o|
                        m << send(make_player_given_id('', object_instance.id, (BATTING_STAT_ATTRS.index(o) + 1))).name[0...22]
                      end
                    end
                  elsif [:total_at_bats, :total_hits].include?(order)
                    Given(:players) do
                      player_order.inject([]) do |m,o|
                        m << send(make_player_given_id('', object_instance.id, (BATTING_STAT_ATTRS.index(o) + 1)))
                      end
                    end
                    Given(:player_names_in_order) do
                      (players + (send('basic_stats_' + object_instance.id.downcase + '_players') - players)).map{|a| a.name[0...22] }
                    end
                  else
                    Given(:player_names_in_order) do
                      ([send(make_player_given_id('', object_instance.id, (BATTING_STAT_ATTRS.index(player_order) + 1)))] +
                      (send('basic_stats_' + object_instance.id.downcase + '_players') -
                       [send(make_player_given_id('', object_instance.id, (BATTING_STAT_ATTRS.index(player_order) + 1)))])).
                        map{|a| a.name[0...22] }
                    end
                  end
                when Team then
                  Given(:player_names_in_order) do
                    [send(make_player_given_id('', object_instance.league.id, object_instance.league.teams.index(object_instance) + 1)).name[0...22]]
                  end
                end

                Then { no_restrict_out_players.map{|a| a[:name]}.should == player_names_in_order }
              end
            end
          end
        end
      end
    end
  end
=end
end

private

def split_out_players(out)
  in_header = false
  keys ||= []
  recs = out.split("\n").inject([]) do |a,line|
    if line =~ /^[[:space:]]*Name/ #header line
      in_header = true
      keys = line.gsub(/^\s+|\s+$/,'').split(/\s+/).map(&:downcase).map(&:to_sym)
    elsif line =~ /^\s+$/ or line.empty?  #blank line
      in_header = false
    elsif in_header
      vals = line.gsub(/^\s+|\s+$/,'').shellsplit
      rec = keys.each_with_index.inject({}) do |m,(k, i)| 
        m[k] = vals[i]
        m
      end
      a << rec
    else
      in_header = false
    end
    a
  end
  recs
end
