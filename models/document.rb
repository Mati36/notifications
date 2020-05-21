
class Document < Sequel::Model
  def validate
    super
    validates_presence [:title, :type, :format, :visibility, :path, :created_at], message: 'Datos en blancos o vacios'
    validates_unique [:path], message: 'Documeto repetido'
  end
  
  #Relations
  many_to_one :user
end