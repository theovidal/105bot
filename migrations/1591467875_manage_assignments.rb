Sequel.migration do
  up do
    create_table(:assignments) do
      primary_key :id
      Integer :agenda, null: false
      String :type, null: false
      String :subject
      String :text, null: false
      String :link
      Date :date, null: false
      Integer :hour
      Boolean :is_weekly, default: false
    end
  end

  down do
    drop_table(:assignments)
  end
end
