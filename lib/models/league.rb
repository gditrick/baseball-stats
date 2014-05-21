class League < Sequel::Model
  plugin :timestamps

  one_to_many :players
  one_to_many :teams
end
