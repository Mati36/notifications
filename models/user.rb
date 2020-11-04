class User < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence %i[name lastname dni email password], message: 'Datos en blancos o vacios'
    validates_integer :dni, message: 'Dni no es un numero'
    validates_unique :dni, :email, message: 'Datos repetidos'
    validates_format(/\A.*@.*\..*\z/, :email, message: 'No es un formato de mail valido')
  end

  # Relations

  # to document
  one_to_many :documents_users
  many_to_many :documents

  # to topic
  one_to_many :topics_users
  many_to_many :topics

  dataset_module do
    # def correct_password(user, password)
    #   BCrypt::Password.new(user.password) == password
    # end

    # def encrypt_password(password)
    #   BCrypt::Password.create(password, cost: 4)
    # end

    # def create_user(name, lastname, dni, email, password)
    #   user = User.new(name: name, lastname: lastname, dni: dni,
    #                   email: email, password: User.encrypt_password(password))
  
    #   user.update(is_admin: true) if User.all.length <= 0
  
    #   user
    # end

    def find_user_id(current_id)
      User.find(id: current_id)
    end
  
    def find_user_dni(current_dni)
      User.find(dni: current_dni)
    end
  
    def find_user_email(current_email)
      User.find(email: current_email)
    end
  end  
end
