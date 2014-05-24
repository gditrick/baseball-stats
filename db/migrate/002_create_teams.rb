Sequel.migration do 
  up do
    create_table :teams do
      String      :team_id
      foreign_key :league_id, :leagues, type: String, null: false
      String      :name

      DateTime    :created_at
      DateTime    :updated_at

      primary_key [:team_id, :league_id], name: :teams_pk
      index       :name, unique: false
    end
  end

  down do
    drop_index :teams, :name
    drop_table :teams
  end
end
