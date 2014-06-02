require File.join(File.dirname(File.expand_path(__FILE__)), "../spec_helper")
require 'models/batting_stat' 
describe BattingStat do
  Then { should respond_to(:player) }
  And  { should respond_to(:team) }
  And  { should respond_to(:league) }

  context ".new" do
    Given(:stat) { BattingStat.new }
    Then { stat.should respond_to(:player) }
    And  { stat.should respond_to(:team) }
    And  { stat.should respond_to(:league) }
  end

  describe "dataset methods/scopes" do
    before(:all) do
      al = FactoryGirl.create(:league_with_teams, id: 'AL')
      nl = FactoryGirl.create(:league_with_teams, id: 'NL')
      players = 3.times.inject([]) do |m,i|
        player_id = sprintf("P%d", i+1)
        m << FactoryGirl.create(:player, id: player_id)
      end

      create(:batting_stat, :with_nil_data,  year: '2011', league: al, player: players[0], team: al.teams[0])
      create(:batting_stat, :with_zero_data,  year: '2011', league: al, player: players[0], team: al.teams[0])
      create(:batting_stat, year: '2011', league: al, player: players[0], team: al.teams[0],
             games: 15, at_bats: 20, runs: 3, hits: 6, doubles: 1, triples: 2, home_runs: 1, rbi: 5, stolen_bases: 3, caught_stealing: 1)
      create(:batting_stat, year: '2012', league: al, player: players[0], team: al.teams[2],
             games: 32, at_bats: 50, runs: 4, hits: 16, doubles: 6, triples: 2, home_runs: 3, rbi: 15, stolen_bases: 5, caught_stealing: 1)
      create(:batting_stat, year: '2011', league: al, player: players[0], team: al.teams[2],
             games: 104, at_bats: 240, runs: 31, hits: 56, doubles: 10, triples: 3, home_runs: 15, rbi: 65, stolen_bases: 13, caught_stealing: 5)

      create(:batting_stat, year: '2011', league: nl, player: players[1], team: nl.teams[1],
             games: 79, at_bats: 220, runs: 43, hits: 61, doubles: 11, triples: 1, home_runs: 20, rbi: 75, stolen_bases: 10, caught_stealing: 4)
      create(:batting_stat, year: '2011', league: al, player: players[1], team: al.teams[2],
             games: 19, at_bats: 50, runs: 4, hits: 16, doubles: 6, triples: 2, home_runs: 3, rbi: 15, stolen_bases: 5, caught_stealing: 1)
      create(:batting_stat, year: '2012', league: al, player: players[1], team: al.teams[2],
             games: 55, at_bats: 201, runs: 21, hits: 56, doubles: 8, triples: 0, home_runs: 12, rbi: 55, stolen_bases: 5, caught_stealing: 0)

      create(:batting_stat, year: '2010', league: nl, player: players[2], team: nl.teams[1],
             games: 45, at_bats: 45, runs: 9, hits: 14, doubles: 3, triples: 0, home_runs: 2, rbi: 15, stolen_bases: 0, caught_stealing: 0)
      create(:batting_stat, year: '2011', league: nl, player: players[2], team: nl.teams[1],
             games: 124, at_bats: 399, runs: 54, hits: 131, doubles: 16, triples: 2, home_runs: 30, rbi: 89, stolen_bases: 4, caught_stealing: 1)
      create(:batting_stat, year: '2012', league: nl, player: players[2], team: nl.teams[1],
             games: 93, at_bats: 199, runs: 22, hits: 66, doubles: 7, triples: 1, home_runs: 7, rbi: 41, stolen_bases: 6, caught_stealing: 0)
    end
    after(:all) do
      BattingStat.dataset.delete
      Team.dataset.delete
      League.dataset.delete
      Player.dataset.delete
    end

    ["AL", "NL"].each do |league_id|
      Given(("league" + league_id).to_sym) { League[league_id] }
      5.times do |i|
        team_id = sprintf("%c%2.2d", league_id[0], i+1)
        Given(("team" + team_id).to_sym) { Team[team_id, league_id] }
      end
    end

    players = 3.times do |i|
      player_id = sprintf("P%d", i+1)
      Given(("player" + player_id).to_sym) { Player[player_id] }
    end

    context ".defualt_order" do
      describe "SQL contains" do
        Given(:default_order) { BattingStat.default_order }
        When (:sql) { default_order.sql }
        Then { expect(sql).to match(/order by[ ]*["'`]year["'`],[ ]*["'`]league_id["'`],[ ]*["'`]team_id["'`],[ ]*["'`]player_id["'`]/i) }
      end
      describe "records" do
        Given(:stats) { BattingStat.default_order }
        When(:all) { stats.all }
        Then { all.should_not be_empty }
        And { all.size.should == 11 }
        And { all.map(&:year).should == [ "2010",
                                          "2011",
                                          "2011",
                                          "2011",
                                          "2011",
                                          "2011",
                                          "2011",
                                          "2011",
                                          "2012",
                                          "2012",
                                          "2012" ] }
        And { all.map(&:league).should == [ leagueNL,
                                            leagueAL,
                                            leagueAL,
                                            leagueAL,
                                            leagueAL,
                                            leagueAL,
                                            leagueNL,
                                            leagueNL,
                                            leagueAL,
                                            leagueAL,
                                            leagueNL ] }
        And { all.map(&:team).should == [ teamN02,
                                          teamA01,
                                          teamA01,
                                          teamA01,
                                          teamA03,
                                          teamA03,
                                          teamN02,
                                          teamN02,
                                          teamA03,
                                          teamA03,
                                          teamN02 ] }
        And { all.map(&:player).should == [ playerP3,
                                            playerP1,
                                            playerP1,
                                            playerP1,
                                            playerP1,
                                            playerP2,
                                            playerP2,
                                            playerP3,
                                            playerP1,
                                            playerP2,
                                            playerP3 ] }
      end
    end

    context ".for_year" do
      describe "SQL contains" do
        Given(:for_year) { BattingStat.for_year('2011') }
        When (:sql) { for_year.sql }
        Then { expect(sql).to match(/where[ ]*.*year.[ ]*=[ ]*.*2011/i) }

        Given(:for_year) { BattingStat.for_year(2011) }
        When (:sql) { for_year.sql }
        Then { expect(sql).to match(/where[ ]*.*year.[ ]*=[ ]*.*2011/i) }
      end
      describe "records" do
        Given(:stats) { BattingStat.for_year('2011') }
        When(:all) { stats.all }
        Then { all.should_not be_empty }
        And { all.size.should == 7 }
        And { expect(all.map(&:year).all?{|a| a == "2011"}).to be_true }
        And { all.map(&:league).should == [ leagueAL,
                                            leagueAL,
                                            leagueAL,
                                            leagueAL,
                                            leagueAL,
                                            leagueNL,
                                            leagueNL ] }
        And { all.map(&:team).should == [ teamA01,
                                          teamA01,
                                          teamA01,
                                          teamA03,
                                          teamA03,
                                          teamN02,
                                          teamN02 ] }
        And { all.map(&:player).should == [ playerP1,
                                            playerP1,
                                            playerP1,
                                            playerP1,
                                            playerP2,
                                            playerP2,
                                            playerP3 ] }
      end
    end
    context ".for_league" do
      describe "SQL contains" do
        Given(:for_league) { BattingStat.for_league(leagueAL.id) }
        When (:sql) { for_league.sql }
        Then { expect(sql).to match(/where[ ]*.*league_id.[ ]*=[ ]*.*#{leagueAL.id}/i) }
      end
      describe "records" do
        Given(:stats) { BattingStat.for_league(leagueAL.id) }
        When(:all) { stats.all }
        Then { all.should_not be_empty }
        And { all.size.should == 7 }
        And { expect(all.map(&:league).all?{|a| a == leagueAL}).to be_true }
        And { all.map(&:year).should == [ "2011",
                                          "2011",
                                          "2011",
                                          "2011",
                                          "2011",
                                          "2012",
                                          "2012" ] }
        And { all.map(&:team).should == [ teamA01,
                                          teamA01,
                                          teamA01,
                                          teamA03,
                                          teamA03,
                                          teamA03,
                                          teamA03 ] }
        And { all.map(&:player).should == [ playerP1,
                                            playerP1,
                                            playerP1,
                                            playerP1,
                                            playerP2,
                                            playerP1,
                                            playerP2 ] }
      end
    end
    context ".for_team" do
      describe "SQL contains" do
        Given(:for_team) { BattingStat.for_team(teamN02) }
        When (:sql) { for_team.sql }
        Then { expect(sql).to match(/where[ ]*.*team_id.*[ ]*=[ ]*.*#{teamN02.team_id}.*[ ]*and[ ]*.*league_id.*[ ]*=[ ]*.*#{teamN02.league_id}/i) }
      end
      describe "records" do
        Given(:stats) { BattingStat.for_team(teamN02) }
        When(:all) { stats.all }
        Then { all.should_not be_empty }
        And { all.size.should == 4 }
        And { expect { all.map(&:team).all?{|a| a == teamN02}}.to be_true }
        And { expect { all.map(&:league).all?{|a| a == leagueNL}}.to be_true }
        And { all.map(&:year).should == [ "2010",
                                          "2011",
                                          "2011",
                                          "2012" ] }
        And { all.map(&:player).should == [ playerP3,
                                            playerP2,
                                            playerP3,
                                            playerP3 ] }
      end
    end
    context ".for_player" do
      describe "SQL contains" do
        Given(:for_player) { BattingStat.for_player(playerP1) }
        When (:sql) { for_player.sql }
        Then { expect(sql).to match(/where[ ]*.*id.*[ ]*=[ ]*.*#{playerP1.id}/i) }
      end
      describe "records" do
        Given(:stats) { BattingStat.for_player(playerP1) }
        When(:all) { stats.all }
        Then { all.should_not be_empty }
        And { all.size.should == 5 }
        And { expect(all.map(&:player).all?{|a| a == playerP1}).to be_true }
        And { expect(all.map(&:league).all?{|a| a == leagueAL}).to be_true }
        And { all.map(&:year).should == [ "2011",
                                          "2011",
                                          "2011",
                                          "2011",
                                          "2012" ] }
        And { all.map(&:team).should == [ teamA01,
                                          teamA01,
                                          teamA01,
                                          teamA03,
                                          teamA03 ] }
      end
    end

    context "#average" do
      describe "should handle nil and zero data" do
        Given(:stats) { BattingStat.for_player(playerP1) }
        When(:all) { stats.all }
        Then { all.map(&:average).should == [nil, nil, 0.3, 0.233, 0.32 ] }
        context "on dataset" do
          When(:average) { stats.average  }
          Then { average == 0.252 }
        end
      end
    end

    context "#slugging" do
      describe "should handle nil and zero data" do
        Given(:stats) { BattingStat.for_player(playerP1) }
        When(:all) { stats.all }
        Then { all.map(&:slugging).should == [nil, nil, 0.7, 0.488, 0.7 ] }
        context "on dataset" do
          When(:slugging) { stats.slugging  }
          Then { slugging == 0.535 }
        end
      end
    end

    context "#games" do
      describe "should handle nil and zero data" do
        Given(:stats) { BattingStat.for_player(playerP1) }
        When(:all) { stats.all }
        Then { all.map(&:games).should == [nil, 0, 15, 104, 32] }
        context "total on dataset" do
          When(:total) { stats.total_games  }
          Then { total == 151 }
        end
      end
    end

    context "#at_bats" do
      describe "should handle nil and zero data" do
        Given(:stats) { BattingStat.for_player(playerP1) }
        When(:all) { stats.all }
        Then { all.map(&:at_bats).should == [nil, 0, 20, 240, 50] }
        context "total on dataset" do
          When(:total) { stats.total_at_bats  }
          Then { total == 310 }
        end
      end
    end

    context "#runs" do
      describe "should handle nil and zero data" do
        Given(:stats) { BattingStat.for_player(playerP1) }
        When(:all) { stats.all }
        Then { all.map(&:runs).should == [nil, 0, 3, 31, 4] }
        context "total on dataset" do
          When(:total) { stats.total_runs  }
          Then { total == 38 }
        end
      end
    end

    context "#hits" do
      describe "should handle nil and zero data" do
        Given(:stats) { BattingStat.for_player(playerP1) }
        When(:all) { stats.all }
        Then { all.map(&:hits).should == [nil, 0, 6, 56, 16] }
        context "total on dataset" do
          When(:total) { stats.total_hits  }
          Then { total == 78 }
        end
      end
    end

    context "#doubles" do
      describe "should handle nil and zero data" do
        Given(:stats) { BattingStat.for_player(playerP1) }
        When(:all) { stats.all }
        Then { all.map(&:doubles).should == [nil, 0, 1, 10, 6] }
        context "total on dataset" do
          When(:total) { stats.total_doubles  }
          Then { total == 17 }
        end
      end
    end

    context "#triples" do
      describe "should handle nil and zero data" do
        Given(:stats) { BattingStat.for_player(playerP1) }
        When(:all) { stats.all }
        Then { all.map(&:triples).should == [nil, 0, 2, 3, 2] }
        context "total on dataset" do
          When(:total) { stats.total_triples  }
          Then { total == 7 }
        end
      end
    end

    context "#home_runs" do
      describe "should handle nil and zero data" do
        Given(:stats) { BattingStat.for_player(playerP1) }
        When(:all) { stats.all }
        Then { all.map(&:home_runs).should == [nil, 0, 1, 15, 3] }
        context "total on dataset" do
          When(:total) { stats.total_home_runs  }
          Then { total == 19 }
        end
      end
    end

    context "#rbi" do
      describe "should handle nil and zero data" do
        Given(:stats) { BattingStat.for_player(playerP1) }
        When(:all) { stats.all }
        Then { all.map(&:rbi).should == [nil, 0, 5, 65, 15] }
        context "total on dataset" do
          When(:total) { stats.total_rbi  }
          Then { total == 85 }
        end
      end
    end

    context "#stolen_bases" do
      describe "should handle nil and zero data" do
        Given(:stats) { BattingStat.for_player(playerP1) }
        When(:all) { stats.all }
        Then { all.map(&:stolen_bases).should == [nil, 0, 3, 13, 5] }
        context "total on dataset" do
          When(:total) { stats.total_stolen_bases  }
          Then { total == 21 }
        end
      end
    end

    context "#caught_stealing" do
      describe "should handle nil and zero data" do
        Given(:stats) { BattingStat.for_player(playerP1) }
        When(:all) { stats.all }
        Then { all.map(&:caught_stealing).should == [nil, 0, 1, 5, 1] }
        context "total on dataset" do
          When(:total) { stats.total_caught_stealing  }
          Then { total == 7 }
        end
      end
    end
  end
end
