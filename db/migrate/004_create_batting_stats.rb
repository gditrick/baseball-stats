Sequel.migration do 
  up do
    create_table :batting_stats do
      primary_key :id, type: Bignum
      foreign_key :player_id, :players, type: String 
      foreign_key :league_id, :leagues, type: String 
      String      :team_id
      foreign_key [:team_id, :league_id], :teams
      String      :year
      Fixnum      :games
      Fixnum      :at_bats
      Fixnum      :runs
      Fixnum      :hits
      Fixnum      :doubles
      Fixnum      :triples
      Fixnum      :home_runs
      Fixnum      :rbi
      Fixnum      :stolen_bases
      Fixnum      :caught_stealing

      DateTime    :created_at
      DateTime    :updated_at

      index [:player_id, :team_id, :year], unique: false
    end
  end

  down do
    drop_index :batting_stats, [:player_id, :team_id, :year]
    drop_table :batting_stats
  end
end
