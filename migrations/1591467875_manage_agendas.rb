Sequel.migration do
  up do
    create_table(:agendas) do
      primary_key :id
      String :name
      Integer :snowflake, null: false
      Integer :server, null: false
      Integer :channel, null: false
    end
  end

  down do
    drop_table(:agendas)
  end
end
