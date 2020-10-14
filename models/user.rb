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
    def correct_password(user, password)
      BCrypt::Password.new(user.password) == password
    end

    def encrypt_password(password)
      BCrypt::Password.create(password, cost: 4)
    end
  end
end
