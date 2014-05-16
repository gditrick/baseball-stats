class BattingStat < Sequel::Model
  plugin :timestamps

  many_to_one :player
  many_to_one :team
  many_to_one :league
end
