# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

League.dataset.delete
League.unrestrict_primary_key
League.create(id: 'AL', name: 'American League')
League.create(id: 'NL', name: 'National League')

Team.dataset.delete
Team.unrestrict_primary_key
Team.create(team_id: 'BAL', league_id: 'AL', name: 'Baltimore Orioles')
Team.create(team_id: 'BOS', league_id: 'AL', name: 'Boston Red Sox')
Team.create(team_id: 'CHA', league_id: 'AL', name: 'Chicago White Sox')
Team.create(team_id: 'CLE', league_id: 'AL', name: 'Cleveland Indians')
Team.create(team_id: 'DET', league_id: 'AL', name: 'Detroit Tigers')
Team.create(team_id: 'HOU', league_id: 'AL', name: 'Houston Atros')
Team.create(team_id: 'KCA', league_id: 'AL', name: 'Kansas City Royals')
Team.create(team_id: 'LAA', league_id: 'AL', name: 'Los Angeles Angels')
Team.create(team_id: 'MIN', league_id: 'AL', name: 'Minnesota Twins')
Team.create(team_id: 'NYA', league_id: 'AL', name: 'New York Yankees')
Team.create(team_id: 'OAK', league_id: 'AL', name: 'Oakland Athletics')
Team.create(team_id: 'SEA', league_id: 'AL', name: 'Seattle Mariners')
Team.create(team_id: 'TBA', league_id: 'AL', name: 'Tampa Bay Rays')
Team.create(team_id: 'TEX', league_id: 'AL', name: 'Texas Rangers')
Team.create(team_id: 'TOR', league_id: 'AL', name: 'Toronto Blue Rays')

Team.create(team_id: 'ARI', league_id: 'NL', name: 'Arizona Diamondbacks')
Team.create(team_id: 'ATL', league_id: 'NL', name: 'Atlanta Braves')
Team.create(team_id: 'CHN', league_id: 'NL', name: 'Chicago Cubs')
Team.create(team_id: 'CIN', league_id: 'NL', name: 'Cincinnati Reds')
Team.create(team_id: 'COL', league_id: 'NL', name: 'Coloradro Rockies')
Team.create(team_id: 'FLO', league_id: 'NL', name: 'Florida Marlins')
Team.create(team_id: 'HOU', league_id: 'NL', name: 'Houston Atros')
Team.create(team_id: 'LAN', league_id: 'NL', name: 'Los Angeles Dodgers')
Team.create(team_id: 'MIA', league_id: 'NL', name: 'Miami Marlins')
Team.create(team_id: 'MIL', league_id: 'NL', name: 'Milwaukee Brewers')
Team.create(team_id: 'NYN', league_id: 'NL', name: 'New York Mets')
Team.create(team_id: 'PHI', league_id: 'NL', name: 'Philadelphia Phillies')
Team.create(team_id: 'PIT', league_id: 'NL', name: 'Pittsburg Pirates')
Team.create(team_id: 'SDN', league_id: 'NL', name: 'San Diego Padres')
Team.create(team_id: 'SFN', league_id: 'NL', name: 'San Francisco Giants')
Team.create(team_id: 'SLN', league_id: 'NL', name: 'St. Louis Cardinals')
Team.create(team_id: 'WAS', league_id: 'NL', name: 'Washington Nationals')
