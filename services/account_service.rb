class Account_service 
    require './models/user.rb'
    require './exceptions/validation_model_error.rb'
    require './services/user_service.rb'

    def self.sign_up(name,lastname,dni,email,pwd)
     
        user = User_service.create_user(name,lastname,dni,email,pwd)
        
        if !user.valid?
           raise Validation_model_error.new("Usuario no valido")      
        end
        user.save
        User.order(user.id)
        
    end 

end     