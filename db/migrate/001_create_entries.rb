Sequel.migration do
  change do
    create_table :entries do
      primary_key :id
      String :reason
      String :username
      String :response
      DateTime :date
    end
  end
end
