class Team < Sequel::Model
  attr_accessor :id  # for FactoryGirl stubbing
  set_primary_key [:team_id, :league_id]
  plugin :timestamps

  many_to_one :league

  one_to_many :batting_stats, key: [:team_id, :league_id]
end
