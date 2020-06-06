Sequel.migration do
  up do
    create_table(:messages) do
      primary_key :id
      Integer :agenda, null: false
      Integer :message, null: false
      Boolean :weekly, default: false
      Date :date, null: false
    end
  end

  down do
    drop_table(:messages)
  end
end
