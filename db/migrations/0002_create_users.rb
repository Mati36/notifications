Sequel.migration do 

    up do 
        add_column :users, :lastname,   String,  null: false 
        add_column :users, :dni,        Integer, null: false 
        add_column :users, :email,      String,  null: false 
        add_column :users, :password,   String,  null: false 
        add_column :users, :type,       String,  null: false
		add_column :users, :created_at, DateTime    
        add_column :users, :updated_at, DateTime
        set_column_default :users,      :type,  'user'
    end 

    down do 
        drop_column :users, :lastname
        drop_column :users, :dni
        drop_column :users, :email
        drop_column :users, :password
        drop_column :users, :created_at
        drop_column :users, :updated_at
    
    end  
end    