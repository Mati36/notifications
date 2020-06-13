Sequel.migration do
	up do
		create_table(:documents_users) do
			foreign_key 	:document_id, 	:documents, 	null: false
			foreign_key 	:user_id, 		:users, 		null: false
			primary_key 	[:document_id, 	:user_id]
			index 			[:document_id, 	:user_id]
			TrueClass       :checked,    					:default => false
			TrueClass       :favorite,    					:default => false
			TrueClass       :tag,    						:default => false
			TrueClass       :check_notification,    		:default => false
			DateTime        :created_at,    				default: Sequel::CURRENT_TIMESTAMP
      		DateTime        :updated_at,    				default: Sequel::CURRENT_TIMESTAMP
		end
	end
	 down do
		 drop_table :documents_users
	 end
end