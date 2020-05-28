Sequel.migration do                                                                                           
  up do                                                                                                       
    create_table(:users) do                                                                                   
      primary_key   :id       
      String        :name,        null: false 
      String        :lastname,    null: false 
      Integer       :dni,         null: false 
      String        :email,       null: false 
      String        :password,    null: false 
      FalseClass    :is_admin,    :default => false
      String        :avatar_path, :default => '/images/avatars/default.png'
      DateTime      :created_at     
      DateTime      :updated_at 
    end
  end 
 
  down do                                                                                                     
    drop_table(:users)                                                                                        
  end                                                                                                         
end
