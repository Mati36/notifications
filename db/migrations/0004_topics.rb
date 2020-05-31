Sequel.migration do
	up do
		create_table(:topics) do
            primary_key 	:id
            String          :name,                           null: false
        end
	end
	 down do
		 drop_table :topics
	 end
end