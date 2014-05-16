Sequel.migration do 
  up do
    create_table :teams do
      primary_key :id, type: String, auto_increment: false
      foreign_key :league_id, :leagues, type: String, null: false
      String      :name

      DateTime    :created_at
      DateTime    :updated_at

      index       :name, unique: true
    end
  end

  down do
    drop_index :teams, :name
    drop_table :teams
  end
end
