require 'rubygems'
require 'simplecov'

SimpleCov.start do
  add_group "Models", "lib/models"
  add_group "Commands", "lib/commands"
  add_group "Formatters", "lib/formatters"

  add_filter "/db/"
  add_filter "/spec/"
end
     
ENV['BUNDLE_GEMFILE'] ||= File.expand_path(File.join('..', '..', 'Gemfile'), __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

Bundler.require(:default, ENV['APP_ENV'] || 'test')

libpath = File.expand_path(File.join('..', 'lib'),__FILE__)
$:.unshift(libpath) unless $:.include?(libpath)

require "commands"

config = BaseballStats::Config.new.invoke(:load_config)
db_commands = BaseballStats::Db.new
db = db_commands.invoke :connect, [config.database]
db_commands.invoke :migrate, [db, config.schema_scripts_path]

        
FileList[File.expand_path(File.join("..", "..", "lib", "models", "**", "*.rb"), __FILE__)].each { |f| load f }
FileList[File.expand_path(File.join("..", "..", "lib", "formatters", "**", "*.rb"), __FILE__)].each { |f| load f }
Dir[File.expand_path(File.join("..", "factories", "**", "*.rb"), __FILE__)].each { |f| load f }
Dir[File.expand_path(File.join("..", "support", "**", "*.rb"), __FILE__)].each { |f| load f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

BATTING_STAT_ATTRS=[:games, :at_bats, :runs, :hits, :doubles, :triples, :home_runs, :rbi, :stolen_bases, :caught_stealing]

def make_player_id(prefix, league_id, count)
  sprintf("%s-%sP%3.3d", prefix, league_id, count)
end

def make_player_given_id(prefix, league_id, count)
  make_player_id(prefix, league_id, count).split('-').last.downcase
end

def make_team_id(league_id, count)
  sprintf("%s%3.3d", league_id, count)
end

def create_basic_data(prefix, year)
  ["AL", "NL"].each do |league_id|
    FactoryGirl.create(:league_with_teams, id: league_id, teams_count: BATTING_STAT_ATTRS.size)
  end
  League.each do |league|
    BATTING_STAT_ATTRS.each_with_index do |attr, i|
      player = FactoryGirl.create(:player, id: make_player_id(prefix, league.id, i+1))
      create(:batting_stat, :with_zero_data, year: year, league: league, player: player, team: league.teams[i], attr => 1)
    end
  end
end

def basic_givens(prefix)
  ["AL", "NL"].each do |league_id|
    Given(("league" + league_id).to_sym) { League[league_id] }
    BATTING_STAT_ATTRS.each_index do |i|
      team_id = make_team_id(league_id, i+1)
      Given(("team%s" % team_id).to_sym) { Team[team_id, league_id] }
      player_id = make_player_id(prefix, league_id, i+1)
      given_id =  make_player_given_id(prefix, league_id, i+1)
      Given(given_id.to_sym) { Player[player_id] }
    end
  end
  Given(:basic_leagues) { [leagueAL, leagueNL] }
  Given(:basic_stats_leagues) do
     BATTING_STAT_ATTRS.inject([]) {|a,i| a << leagueAL} +
     BATTING_STAT_ATTRS.inject([]) {|a,i| a << leagueNL}
  end
  Given(:basic_stats_teams) do
     BATTING_STAT_ATTRS.each_index.inject([]) {|a,i| a << send('team' + make_team_id('AL', i+1))} +
     BATTING_STAT_ATTRS.each_index.inject([]) {|a,i| a << send('team' + make_team_id('NL', i+1))}
  end
  Given(:basic_stats_players) do
     BATTING_STAT_ATTRS.each_index.inject([]) {|a,i| a << send(make_player_given_id('', 'AL', i+1))} +
     BATTING_STAT_ATTRS.each_index.inject([]) {|a,i| a << send(make_player_given_id('', 'NL', i+1))}
  end
end
=begin
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
=end
