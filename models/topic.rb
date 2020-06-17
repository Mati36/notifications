class Topic < Sequel::Model
   
    plugin :validation_helpers
    
    def validate
      super
      validates_presence [:name], message: 'Datos en blancos o vacios'
      validates_unique :name, message: 'Datos repetidos'
      
    end
    
    many_to_many :users
    many_to_many :documents

    one_to_many :documents_topics
    one_to_many :topics_users 
    
end