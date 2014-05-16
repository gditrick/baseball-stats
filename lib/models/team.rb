class Team < Sequel::Model
  plugin :timestamps

  many_to_one :league

  one_to_many :batting_stats
end
