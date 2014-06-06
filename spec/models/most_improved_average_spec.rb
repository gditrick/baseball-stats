require File.join(File.dirname(File.expand_path(__FILE__)), "../spec_helper")
require 'models/most_improved_average'

describe MostImprovedAverage do

  it_should_behave_like "BasicMostImprovedStats"

  context ".new" do
    Given(:avg_stat) { MostImprovedAverage.new(stats: BattingStat.all, prev_stats: BattingStat.all) }
    Then { avg_stat.should respond_to(:average) }
    Then { avg_stat.should respond_to(:prev_average) }
    Then { avg_stat.should respond_to(:average_diff) }
  end

  describe "with BattingStat datasets" do
    before(:all) do
      create_basic_data(MostImprovedAverage.to_s, '2011')
      create_basic_prev_data(MostImprovedAverage.to_s, '2010')
    end
    after(:all) do
      BattingStat.dataset.delete
      Team.dataset.delete
      League.dataset.delete
      Player.dataset.delete
    end

    basic_givens(MostImprovedAverage.to_s)

    describe "for_year('2011') no records with AB at the default 200" do
      Given(:stats) { MostImprovedAverage.new(stats: BattingStat.for_year('2011'),
                                              prev_stats: BattingStat.for_year('2010')) }
      context "#most_improved" do
        When(:most_improved) { stats.most_improved }
        Then { expect(most_improved).to be_nil }
      end
      context "#top" do
        When(:top) { stats.top }
        Then { expect(top).to be_empty }
      end
      context "#average" do
        When(:total) { stats.average }
        Then { expect(total).not_to be_nil }
        And { total == 0.8 }
      end
      context "#prev_average" do
        When(:total) { stats.prev_average }
        Then { expect(total).not_to be_nil }
        And { total == 0.8 }
      end
      context "#average_diff" do
        When(:total) { stats.average_diff }
        Then { expect(total).not_to be_nil }
        And { total == 0.0 }
      end
    end

    describe "for_year('2011') no AB restriction" do
      Given(:stats) { MostImprovedAverage.new(stats: BattingStat.for_year('2011'),
                                              prev_stats: BattingStat.for_year('2010'),
                                              restrict: nil) }
      Given(:most_improved_player) { send(make_player_given_id('', 'AL', (BATTING_STAT_ATTRS.index(:at_bats) * BASIC_DATA_PLAYERS_COUNT + 1))) }
      context "#most_improved" do
        When(:most_improved) { stats.most_improved }
        Then { expect(most_improved).not_to be_nil }
        When(:player) { most_improved.player }
        Then { expect(player).to eql(most_improved_player) }
        When(:player_stats) { most_improved.stats }
        Then { player_stats.should be_a(Sequel::Dataset) }
        When(:player_stats_sql) { player_stats.sql }
        Then { expect(player_stats_sql).to match(/where[ ]*.*year.*[ ]*=[ ]*.*2011.*[ ]*and[ ]*.*player_id.*[ ]*=[ ]*.*#{most_improved_player.id}/i) }
      end
      context "#top" do
        When(:top) { stats.top }
        Then { expect(top).not_to be_empty }
        And  { top.size.should == 3 }
      end
      context "#average" do
        When(:total) { stats.average }
        Then { expect(total).not_to be_nil }
        And { total == 0.8 }
      end
      context "#prev_average" do
        When(:total) { stats.prev_average }
        Then { expect(total).not_to be_nil }
        And { total == 0.8 }
      end
      context "#average_diff" do
        When(:total) { stats.average_diff }
        Then { expect(total).not_to be_nil }
        And { total == 0.0 }
      end
    end
  end
end
