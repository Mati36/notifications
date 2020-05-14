Sequel.migration do                                                                                           
  up do                                                                                                       
    create_table(:users) do                                                                                   
      primary_key   :dni       
      String        :name,    null: false 
    end
  end                                                                                                         
  down do                                                                                                     
    drop_table(:users)                                                                                        
  end                                                                                                        
end
