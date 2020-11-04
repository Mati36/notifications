class User_service 
    require './models/user.rb'
    require './exceptions/validation_model_error.rb'
 
    def self.correct_password(user, password)
        BCrypt::Password.new(user.password) == password
    end

    def self.encrypt_password(password)
        BCrypt::Password.create(password, cost: 4)
    end

    def self.create_user(name, lastname, dni, email, password)
        user = User.new(name: name, lastname: lastname, dni: dni,
                        email: email, password: User.encrypt_password(password))

        user.update(is_admin: true) if User.all.length <= 0
        user
    end

    def self.change_password(current_user, current_pass, new_pwd, rep_new_pwd) 
        if correct_password(current_user, current_pass) && new_pwd == rep_new_pwd
            current_user.update(password: encrypt_password(new_pwd)) 
        else
            raise Validation_model_error.new("contraseña no valida")
        end     
    end  
    
    def self.add_admin(user_id)
        user = User.find_user_id(user_id)
        unless user
            raise Validation_model_error.new("Usuario no existe")
        end 
        user.update(is_admin: true)
    end 
    
    def self.del_admin(user_id)
        user = User.find_user_id(user_id)
        unless user
            raise Validation_model_error.new("Usuario no existe")
        end 
        user.update(is_admin: false)
    end   
    
    def self.del_user(user_id)
        user = User.find_user_id(user_id)
        unless user
            raise Validation_model_error.new("Usuario no existe")
        end 
        user.remove_all_documents
        user.remove_all_topics
        user.delete
   end    
end    