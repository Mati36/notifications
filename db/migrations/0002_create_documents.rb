Sequel.migration do                                                                                           
  up do                                                                                                       
    create_table(:documents) do                                                                                   
      primary_key     :id                                                                                         
      String          :title,         null: false 
      String          :type,          null: false 
      String          :format,        null: false 
      TrueClass       :visibility,    null: false 
      String          :path,          null: false
      String          :description
      foreign_key     :user_id,       :users 
      DateTime        :created_at,     null: false
    end 
  end                                                                                                          
  
  down do                                                                                                     
    drop_table(:documents)                                                                                        
  end                                                                                                         
end

