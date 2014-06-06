require File.join(File.dirname(File.expand_path(__FILE__)), "../spec_helper")
describe BattingStat do
  Then { should respond_to(:player) }
  And  { should respond_to(:team) }
  And  { should respond_to(:league) }

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
        Then { all.size.should == BASIC_DATA_PLAYERS_COUNT * 20 }
        Then { expect(all.map(&:year).all?{|a| a == "2011"}).to be_true }
        Then { all.count{|a| a.league == leagueAL} == BASIC_DATA_PLAYERS_COUNT * 10 }
        Then { all.count{|a| a.league == leagueNL} == BASIC_DATA_PLAYERS_COUNT * 10 }
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
        Then { all.size.should == BASIC_DATA_PLAYERS_COUNT * 20 + 2 }
        Then { expect(all.map(&:year).all?{|a| a == "2011"}).not_to be_true }
        Then { all.count{|a| a.year == '2011'} == BASIC_DATA_PLAYERS_COUNT * 20 }
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
        Given(:for_league) { BattingStat.for_league(leagueAL) }
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
        Given(:for_league_stats) { BattingStat.for_league(leagueAL) }
        When(:all) { stats.all }
        Then { all.should_not be_empty }
        Then { all.size.should == BASIC_DATA_PLAYERS_COUNT * 20 +2 }
        Then { expect(all.map(&:league).all?{|a| a == leagueAL}).not_to be_true }
        Then { all.count{|a| a.league == leagueAL} == BASIC_DATA_PLAYERS_COUNT * 10 + 2 }
        Then { all.count{|a| a.league == leagueNL} == BASIC_DATA_PLAYERS_COUNT * 10 }
        Then { all.map(&:league).should == basic_stats_leagues + [League.first, League.first] }
        Then { all.map(&:team).should == basic_stats_teams + [Team.first, Team.first] }
        Then { all.map(&:player).should ==  basic_stats_players + [Player.first, Player.first] }

        When(:for_league_all) { for_league_stats.all }
        Then { for_league_all.should_not be_empty }
        Then { for_league_all.size.should == BASIC_DATA_PLAYERS_COUNT * 10 + 2}
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
        Then { all.size.should == BASIC_DATA_PLAYERS_COUNT * 20 + 2 }
        Then { expect(all.map(&:team).all?{|a| a == teamNL002}).not_to be_true }
        Then { all.count{|a| a.team == teamNL002} == BASIC_DATA_PLAYERS_COUNT + 2 }
        Then { all.count{|a| a.team != teamNL002} == BASIC_DATA_PLAYERS_COUNT * 20 - BASIC_DATA_PLAYERS_COUNT }
        Then { all.map(&:league).should == basic_stats_leagues + [leagueNL, leagueNL] }
        Then { all.map(&:team).should == basic_stats_teams + [teamNL002, teamNL002] }
        Then { all.map(&:player).should ==  basic_stats_players + [Player.first, Player.first] }

        When(:for_team_all) { for_team_stats.all }
        Then { for_team_all.should_not be_empty }
        Then { for_team_all.size.should == BASIC_DATA_PLAYERS_COUNT + 2 }
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
        Then { all.size.should == BASIC_DATA_PLAYERS_COUNT * 20 + 2}
        Then { expect(all.map(&:player).all?{|a| a == send(player_given_id)}).not_to be_true }
        Then { all.count{|a| a.player == send(player_given_id)} == 3 }
        Then { all.count{|a| a.player != send(player_given_id)} == BASIC_DATA_PLAYERS_COUNT * 20 + 2 - 3}
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
