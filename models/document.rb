
class Document < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:title, :type, :format, :visibility, :path, :created_at], message: 'Datos en blancos o vacios'
    validates_unique [:path], message: 'Documeto repetido'
  end
  
  #Relations
    #user
  one_to_many :documents_users
  many_to_many :users 

    #topic
  one_to_many :documents_topics  
  many_to_many :topics
  
end