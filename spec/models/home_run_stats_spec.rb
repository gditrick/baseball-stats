require File.join(File.dirname(File.expand_path(__FILE__)), "../spec_helper")
require 'models/home_run_stats'

describe HomeRunStats do

  it_should_behave_like "BasicStats"

  context ".new" do
    Given(:hr_stat) { HomeRunStats.new(stats: BattingStat.all) }
    Then { hr_stat.should respond_to(:total_home_runs) }
  end

  describe "with BattingStat datasets" do
    before(:all) do
      create_basic_data(HomeRunStats.to_s, '2011')
    end
    after(:all) do
      BattingStat.dataset.delete
      Team.dataset.delete
      League.dataset.delete
      Player.dataset.delete
    end

    basic_givens(HomeRunStats.to_s)

    describe "for_year('2011') no records with AB at the default 400" do
      Given(:stats) { HomeRunStats.new(stats: BattingStat.for_year('2011')) }
      context "#winner" do
        When(:winner) { stats.winner }
        Then { expect(winner).to be_nil }
      end
      context "#top" do
        When(:top) { stats.top }
        Then { expect(top).to be_empty }
      end
      context "#total_home_runs" do
        When(:total) { stats.total_home_runs }
        Then { expect(total).not_to be_nil }
        And { total == 12 }
      end
    end

    describe "for_year('2011') no AB restriction" do
      Given(:stats) { HomeRunStats.new(stats: BattingStat.for_year('2011'), restrict: nil) }
      Given(:winning_player) { send(make_player_given_id('', 'AL', (BATTING_STAT_ATTRS.index(:home_runs) * BASIC_DATA_PLAYERS_COUNT + 1))) }
      context "#winner" do
        When(:winner) { stats.winner }
        Then { expect(winner).not_to be_nil }
        When(:player) { winner.player }
        Then { expect(player).to eql(winning_player) }
        When(:player_stats) { winner.stats }
        Then { player_stats.should be_a(Sequel::Dataset) }
        When(:player_stats_sql) { player_stats.sql }
        Then { expect(player_stats_sql).to match(/where[ ]*.*year.*[ ]*=[ ]*.*2011.*[ ]*and[ ]*.*player_id.*[ ]*=[ ]*.*#{winning_player.id}/i) }
      end
      context "#top" do
        When(:top) { stats.top }
        Then { expect(top).not_to be_empty }
        And  { top.size.should == 3 }
      end
      context "#total_home_runs" do
        When(:total) { stats.total_home_runs }
        Then { expect(total).not_to be_nil }
        And { total == 12 }
      end
    end
  end
end
