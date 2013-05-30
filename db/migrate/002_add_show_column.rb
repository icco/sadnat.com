Sequel.migration do
  change do
    alter_table(:entries) do
      add_column :show, TrueClass, :default => true
    end
  end
end
