Sequel.migration do 
  up do
    create_table :leagues do
      primary_key :id, type: String, auto_increment: false
      String      :name

      DateTime    :created_at
      DateTime    :updated_at

      index       :name, unique: true
    end
  end

  down do
    drop_index :leagues, :name
    drop_table :leagues
  end
end
