class Document < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence %i[title type format visibility path], message: 'Datos en blanco'
    validates_unique [:path], message: 'Documento repetido'
  end

  # Relations
  # user
  one_to_many :documents_users
  many_to_many :users

  # topic
  one_to_many :documents_topics
  many_to_many :topics

end
