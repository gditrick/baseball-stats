require File.join(File.dirname(File.expand_path(__FILE__)), "../spec_helper")
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
      create_basic_data(BattingStat.to_s, '2011')
    end
    after(:all) do
      BattingStat.dataset.delete
      Team.dataset.delete
      League.dataset.delete
      Player.dataset.delete
    end

    basic_givens(BattingStat.to_s)

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
        Then { all.size.should == 20 }
        Then { expect(all.map(&:year).all?{|a| a == "2011"}).to be_true }
        Then { all.count{|a| a.league == leagueAL} == 10 }
        Then { all.count{|a| a.league == leagueNL} == 10 }
        Then { all.map(&:league).should == basic_stats_leagues }
        Then { all.map(&:team).should == basic_stats_teams }
        Then { all.map(&:player).should == basic_stats_players }
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
        before(:all) do
          create(:batting_stat, :with_nil_data,  year: '2012', league: League.first, player: Player.first, team: Team.first)
          create(:batting_stat, :with_zero_data,  year: '2012', league: League.first, player: Player.first, team: Team.first)
        end
        after(:all) do
          BattingStat.where(year: '2012').delete
        end
        Given(:stats) { BattingStat.default_order }
        Given(:for_year_stats) { BattingStat.for_year('2012') }

        When(:all) { stats.all }
        Then { all.should_not be_empty }
        Then { all.size.should == 22}
        Then { expect(all.map(&:year).all?{|a| a == "2011"}).not_to be_true }
        Then { all.count{|a| a.year == '2011'} == 20 }
        Then { all.count{|a| a.year == '2012'} == 2 }
        Then { all.map(&:league).should == basic_stats_leagues + [League.first, League.first] }
        Then { all.map(&:team).should == basic_stats_teams + [Team.first, Team.first] }
        Then { all.map(&:player).should ==  basic_stats_players + [Player.first, Player.first] }

        When(:for_year_all) { for_year_stats.all }
        Then { for_year_all.should_not be_empty }
        Then { for_year_all.size.should == 2}
        Then { expect(for_year_all.map(&:year).all?{|a| a == "2012"}).to be_true }
        Then { for_year_all.map(&:league).should == [League.first, League.first] }
        Then { for_year_all.map(&:team).should == [Team.first, Team.first] }
        Then { for_year_all.map(&:player).should ==  [Player.first, Player.first] }
      end
    end
    context ".for_league" do
      describe "SQL contains" do
        Given(:for_league) { BattingStat.for_league(leagueAL.id) }
        When (:sql) { for_league.sql }
        Then { expect(sql).to match(/where[ ]*.*league_id.[ ]*=[ ]*.*#{leagueAL.id}/i) }
      end
      describe "records" do
        before(:all) do
          create(:batting_stat, :with_nil_data,  year: '2012', league: League.first, player: Player.first, team: Team.first)
          create(:batting_stat, :with_zero_data,  year: '2012', league: League.first, player: Player.first, team: Team.first)
        end
        after(:all) do
          BattingStat.where(year: '2012').delete
        end
        Given(:stats) { BattingStat.default_order }
        Given(:for_league_stats) { BattingStat.for_league('AL') }
        When(:all) { stats.all }
        Then { all.should_not be_empty }
        Then { all.size.should == 22}
        Then { expect(all.map(&:league).all?{|a| a == leagueAL}).not_to be_true }
        Then { all.count{|a| a.league == leagueAL} == 12 }
        Then { all.count{|a| a.league == leagueNL} == 10 }
        Then { all.map(&:league).should == basic_stats_leagues + [League.first, League.first] }
        Then { all.map(&:team).should == basic_stats_teams + [Team.first, Team.first] }
        Then { all.map(&:player).should ==  basic_stats_players + [Player.first, Player.first] }

        When(:for_league_all) { for_league_stats.all }
        Then { for_league_all.should_not be_empty }
        Then { for_league_all.size.should == 12}
        Then { expect(for_league_all.map(&:league).all?{|a| a == leagueAL}).to be_true }
      end
    end
    context ".for_team" do
      describe "SQL contains" do
        Given(:for_team) { BattingStat.for_team(teamNL002) }
        When (:sql) { for_team.sql }
        Then { expect(sql).to match(/where[ ]*.*team_id.*[ ]*=[ ]*.*#{teamNL002.team_id}.*[ ]*and[ ]*.*league_id.*[ ]*=[ ]*.*#{teamNL002.league_id}/i) }
      end
      describe "records" do
        before(:all) do
          create(:batting_stat, :with_nil_data,  year: '2012', league: League['NL'], player: Player.first, team: Team['NL002', 'NL'])
          create(:batting_stat, :with_zero_data,  year: '2012', league: League['NL'], player: Player.first, team: Team['NL002', 'NL'])
        end
        after(:all) do
          BattingStat.where(year: '2012').delete
        end
        Given(:stats) { BattingStat.default_order }
        Given(:for_team_stats) { BattingStat.for_team(teamNL002) }
        When(:all) { stats.all }
        Then { all.should_not be_empty }
        Then { all.size.should == 22}
        Then { expect(all.map(&:team).all?{|a| a == teamNL002}).not_to be_true }
        Then { all.count{|a| a.team == teamNL002} == 3 }
        Then { all.count{|a| a.team != teamNL002} == 19 }
        Then { all.map(&:league).should == basic_stats_leagues + [leagueNL, leagueNL] }
        Then { all.map(&:team).should == basic_stats_teams + [teamNL002, teamNL002] }
        Then { all.map(&:player).should ==  basic_stats_players + [Player.first, Player.first] }

        When(:for_team_all) { for_team_stats.all }
        Then { for_team_all.should_not be_empty }
        Then { for_team_all.size.should == 3}
        Then { expect(for_team_all.map(&:team).all?{|a| a == teamNL002}).to be_true }
      end
    end
    context ".for_player" do
      Given(:player_given_id) { make_player_given_id(BattingStat.to_s, 'NL', 3) }
      describe "SQL contains" do
        Given(:for_player) { BattingStat.for_player(send(player_given_id)) }
        When (:sql) { for_player.sql }
        Then { expect(sql).to match(/where[ ]*.*id.*[ ]*=[ ]*.*#{send(player_given_id).id}/i) }
      end
      describe "records" do
        before(:all) do
          l = League['NL']
          t = Team['NL002', 'NL']
          p = Player[make_player_id(BattingStat.to_s, 'NL', 3)]
          create(:batting_stat, :with_nil_data,  year: '2012', league: l, team: t, player: p)
          create(:batting_stat, :with_zero_data,  year: '2012', league: l, team: t, player: p)
        end
        after(:all) do
          BattingStat.where(year: '2012').delete
        end
        Given(:stats) { BattingStat.default_order }
        Given(:for_player_stats) { BattingStat.for_player(send(player_given_id)) }
        When(:all) { stats.all }
        Then { all.should_not be_empty }
        Then { all.size.should == 22}
        Then { expect(all.map(&:player).all?{|a| a == send(player_given_id)}).not_to be_true }
        Then { all.count{|a| a.player == send(player_given_id)} == 3 }
        Then { all.count{|a| a.player != send(player_given_id)} == 19 }
        Then { all.map(&:league).should == basic_stats_leagues + [leagueNL, leagueNL] }
        Then { all.map(&:team).should == basic_stats_teams + [teamNL002, teamNL002] }
        Then { all.map(&:player).should ==  basic_stats_players + [send(player_given_id), send(player_given_id)] }

        When(:for_player_all) { for_player_stats.all }
        Then { for_player_all.should_not be_empty }
        Then { for_player_all.size.should == 3}
        Then { expect(for_player_all.map(&:player).all?{|a| a == send(player_given_id)}).to be_true }
      end
    end

    context "#average" do
      Given(:player_given_id) { make_player_given_id(BattingStat.to_s, 'AL', 4) }
      describe "should handle nil and zero data" do
        before(:all) do
          l = League['AL']
          t = Team['AL005', 'AL']
          p = Player[make_player_id(BattingStat.to_s, 'AL', 4)]
          create(:batting_stat, :with_nil_data,  year: '2012', league: l, team: t, player: p)
          create(:batting_stat, :with_zero_data,  year: '2012', league: l, team: t, player: p)
          create(:batting_stat, :with_zero_data,  year: '2012', league: l, team: t, player: p, at_bats: 100, hits: 45)
          create(:batting_stat, :with_zero_data,  year: '2012', league: l, team: t, player: p, at_bats: 100, hits: 25)
        end
        after(:all) do
          BattingStat.where(year: '2012').delete
        end
        Given(:stats) { BattingStat.for_player(send(player_given_id)).for_year('2012') }
        When(:all) { stats.all }
        Then { all.map(&:hits).should == [nil, 0, 45, 25 ] }
        Then { all.map(&:at_bats).should == [nil, 0, 100, 100 ] }
        Then { all.map(&:average).should == [nil, nil, 0.450, 0.250 ] }
        context "on dataset" do
          When(:average) { stats.average  }
          Then { average == 0.350 }
        end
      end
    end

    context "#slugging" do
      Given(:player_given_id) { make_player_given_id(BattingStat.to_s, 'AL', 1) }
      describe "should handle nil and zero data" do
        before(:all) do
          l = League['AL']
          t = Team['AL005', 'AL']
          p = Player[make_player_id(BattingStat.to_s, 'AL', 1)]
          create(:batting_stat, :with_nil_data,  year: '2012', league: l, team: t, player: p)
          create(:batting_stat, :with_zero_data,  year: '2012', league: l, team: t, player: p)
          create(:batting_stat, :with_zero_data,  year: '2012', league: l, team: t, player: p, at_bats: 100, hits: 45, doubles: 2, triples: 2, home_runs: 2)
          create(:batting_stat, :with_zero_data,  year: '2012', league: l, team: t, player: p, at_bats: 100, hits: 25, doubles: 2, triples: 2, home_runs: 2)
        end
        after(:all) do
          BattingStat.where(year: '2012').delete
        end
        Given(:stats) { BattingStat.for_player(send(player_given_id)).for_year('2012') }
        When(:all) { stats.all }
        Then { all.map(&:at_bats).should == [nil, 0, 100, 100 ] }
        Then { all.map(&:hits).should == [nil, 0, 45, 25 ] }
        Then { all.map(&:doubles).should == [nil, 0, 2, 2 ] }
        Then { all.map(&:triples).should == [nil, 0, 2, 2 ] }
        Then { all.map(&:home_runs).should == [nil, 0, 2, 2 ] }
        Then { all.map(&:slugging).should == [nil, nil, 0.570, 0.370 ] }
        context "on dataset" do
          When(:slugging) { stats.slugging  }
          Then { slugging == 0.470 }
        end
      end
    end

    BATTING_STAT_ATTRS.each do |attr|
      context "###{attr.to_s}" do
        Given(:player_given_id) { make_player_given_id(BattingStat.to_s, 'AL', 1) }
        describe "should handle nil and zero data" do
          before(:all) do
            l = League['AL']
            t = Team['AL005', 'AL']
            p = Player[make_player_id(BattingStat.to_s, 'AL', 1)]
            create(:batting_stat, :with_nil_data,  year: '2012', league: l, team: t, player: p)
            create(:batting_stat, :with_zero_data,  year: '2012', league: l, team: t, player: p)
            create(:batting_stat, :with_zero_data,  year: '2012', league: l, team: t, player: p, attr => 1)
            create(:batting_stat, :with_zero_data,  year: '2012', league: l, team: t, player: p, attr => 2)
          end
          after(:all) do
            BattingStat.where(year: '2012').delete
          end
          Given(:stats) { BattingStat.for_player(send(player_given_id)).for_year('2012') }
          When(:all) { stats.all }
          Then { all.map{|a| a.send(attr)}.should == [nil, 0, 1, 2] }
          context "total on dataset" do
            When(:total) { stats.send('total_' + attr.to_s) }
            Then { total == 3 }
          end
        end
      end
    end
  end
end

=begin
    context "#at_bats" do
      Given(:player_given_id) { make_player_given_id(BattingStat.to_s, 'AL', 1) }
      describe "should handle nil and zero data" do
        before(:all) do
          l = League['AL']
          t = Team['AL005', 'AL']
          p = Player[make_player_id(BattingStat.to_s, 'AL', 1)]
          create(:batting_stat, :with_nil_data,  year: '2012', league: l, team: t, player: p)
          create(:batting_stat, :with_zero_data,  year: '2012', league: l, team: t, player: p)
          create(:batting_stat, :with_zero_data,  year: '2012', league: l, team: t, player: p, games: 1)
          create(:batting_stat, :with_zero_data,  year: '2012', league: l, team: t, player: p, games: 2)
        end
        after(:all) do
          BattingStat.where(year: '2012').delete
        end
        Given(:stats) { BattingStat.for_player(send(player_given_id)).for_year('2012') }
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
=end
