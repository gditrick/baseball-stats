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
Team.create(id: 'BAL', league_id: 'AL', name: 'Baltimore Orioles')
Team.create(id: 'BOS', league_id: 'AL', name: 'Boston Red Sox')
Team.create(id: 'CHA', league_id: 'AL', name: 'Chicago White Sox')
Team.create(id: 'CLE', league_id: 'AL', name: 'Cleveland Indians')
Team.create(id: 'DET', league_id: 'AL', name: 'Detroit Tigers')
Team.create(id: 'HOU', league_id: 'AL', name: 'Houston Atros')
Team.create(id: 'KCA', league_id: 'AL', name: 'Kansas City Royals')
Team.create(id: 'LAA', league_id: 'AL', name: 'Los Angeles Angels')
Team.create(id: 'MIN', league_id: 'AL', name: 'Minnesota Twins')
Team.create(id: 'NYA', league_id: 'AL', name: 'New York Yankees')
Team.create(id: 'OAK', league_id: 'AL', name: 'Oakland Athletics')
Team.create(id: 'SEA', league_id: 'AL', name: 'Seattle Mariners')
Team.create(id: 'TBA', league_id: 'AL', name: 'Tampa Bay Rays')
Team.create(id: 'TEX', league_id: 'AL', name: 'Texas Rangers')
Team.create(id: 'TOR', league_id: 'AL', name: 'Toronto Blue Rays')

Team.create(id: 'ARI', league_id: 'NL', name: 'Arizona Diamondbacks')
Team.create(id: 'ATL', league_id: 'NL', name: 'Atlanta Braves')
Team.create(id: 'CHN', league_id: 'NL', name: 'Chicago Cubs')
Team.create(id: 'CIN', league_id: 'NL', name: 'Cincinnati Reds')
Team.create(id: 'COL', league_id: 'NL', name: 'Coloradro Rockies')
Team.create(id: 'FLO', league_id: 'NL', name: 'Florida Marlins')
Team.create(id: 'LAN', league_id: 'NL', name: 'Los Angeles Dodgers')
Team.create(id: 'MIA', league_id: 'NL', name: 'Miami Marlins')
Team.create(id: 'MIL', league_id: 'NL', name: 'Milwaukee Brewers')
Team.create(id: 'NYN', league_id: 'NL', name: 'New York Mets')
Team.create(id: 'PHI', league_id: 'NL', name: 'Philadelphia Phillies')
Team.create(id: 'PIT', league_id: 'NL', name: 'Pittsburg Pirates')
Team.create(id: 'SDN', league_id: 'NL', name: 'San Diego Padres')
Team.create(id: 'SFN', league_id: 'NL', name: 'San Francisco Giants')
Team.create(id: 'SLN', league_id: 'NL', name: 'St. Louis Cardinals')
Team.create(id: 'WAS', league_id: 'NL', name: 'Washington Nationals')
