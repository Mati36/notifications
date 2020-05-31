Sequel.migration do
	up do
		create_table(:topics_users) do
            foreign_key 	:user_id, 	:users, 	null: false
			foreign_key 	:topic_id,  :topics,    null: false
			primary_key 	[:user_id, 	:topic_id]
			index 			[:user_id, 	:topic_id]
        end
	end
	 down do
		 drop_table :topics_users
	 end
end