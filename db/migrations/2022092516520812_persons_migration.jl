module PersonsMigration

import SearchLight.Migrations: create_table, column, columns, pk, add_index, drop_table, add_indices

function up()
  create_table(:persons) do
    [
      pk()
      columns([
        :name => :string
        :work => :string
        :age => :integer
        :address => :string
      ])
    ]
  end

  add_indices(:persons, :name, :work, :age, :address)
end

function down()
  drop_table(:persons)
end

end
