class Player < Sequel::Model
  plugin :timestamps

  one_to_many :batting_stats
end
