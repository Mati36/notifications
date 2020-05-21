
class User < Sequel::Model
    plugin :validation_helpers
    
    def validate
      super
      validates_presence [:name, :lastname, :dni, :email, :password, :role], message: 'Datos en blancos o vacios'
      validates_integer :dni, message: 'Dni no es un Integer'
      validates_unique [:dni, :email], message: 'Datos repetidos'
      validates_format /\A.*@.*\..*\z/, :email, message: 'Email invalido'
    end

    # Relations 
    one_to_many :documents
end