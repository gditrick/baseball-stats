class League < Sequel::Model
  plugin :timestamps

  one_to_many :teams
end
