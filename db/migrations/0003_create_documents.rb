Sequel.migration do                                                                                           
  up do                                                                                                       
    create_table(:documents) do                                                                                   
      primary_key     :id                                                                                         
      String          :title,         null: false 
      String          :type,          null: false 
      String          :format,        null: false 
      foreign_key     :creator_dni,   :users
      DateTime        :created_at 
      DateTime        :updated_at
    end 
  end                                                                                                          
  
  down do                                                                                                     
    drop_table(:documents)                                                                                        
  end                                                                                                         
end

