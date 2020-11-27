Sequel.migration do
  up do
    create_table(:documents_topics) do
      foreign_key :document_id,	:documents,	null: false
      foreign_key 	:topic_id,	:topics,	null: false
      primary_key 	%i[document_id topic_id]
      index %i[document_id topic_id]
    end
  end
  down do
    drop_table :documents_topics
  end
end
