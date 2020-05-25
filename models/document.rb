
class Document < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:title, :type, :format, :visibility, :path, :created_at], message: 'Datos en blancos o vacios'
    validates_unique [:path], message: 'Documeto repetido'
  end
  
  #Relations
  one_to_many :documents_users
  many_to_many :users #por esto no sube
  # many_to_one :user
  
end