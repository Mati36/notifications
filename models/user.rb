
class User < Sequel::Model
    plugin :validation_helpers
    
    def validate
      super
      validates_presence [:name, :lastname, :dni, :email, :password], message: 'Datos en blancos o vacios'
      validates_integer :dni, message: 'Dni no es un numero'
      validates_unique [:dni, :email], message: 'Datos repetidos'
    end

    # Relations 
    one_to_many :documents
end