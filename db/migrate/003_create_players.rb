Sequel.migration do 
  up do
    create_table :players do
      primary_key :id, :type => String, auto_increment: false
      String      :birth_year
      String      :first_name
      String      :last_name

      DateTime    :created_at
      DateTime    :updated_at

      index [:last_name, :first_name], unique: false
    end
  end

  down do
    drop_index :players, [:last_name, :first_name]
    drop_table :players
  end
end
