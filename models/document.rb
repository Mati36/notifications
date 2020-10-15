class Document < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence %i[title type format visibility path], message: 'Datos en blanco o vacios'
    validates_unique [:path], message: 'Documento repetido'
  end

  # Relations
  # user
  one_to_many :documents_users
  many_to_many :users

  # topic
  one_to_many :documents_topics
  many_to_many :topics

  dataset_module do
    
    def delete_doc(document)
      document&.update(visibility: false) unless document.nil?
    end

    def user_cheked_document(document,current_user)
      doc = Tag.find(user_id: current_user.id, document_id: document.id) 
      if doc.nil?
        current_user.add_document(document)
        doc = Tag.find(user_id: current_user.id, document_id: document.id)
      end
      doc.update(checked: true, check_notification: true)
    end

    def user_add_favorite_document(document,current_user)
      doc = Tag.find(user_id: current_user.id, document_id: document.id)
      if doc.nil?
        current_user.add_document(document)
        doc = Tag.find(user_id: current_user.id, document_id: document.id)
      end
      doc.update(favorite: true, check_notification: true)
    end

    def user_del_favorite_document(document,current_user)
      doc = Tag.find(user_id: current_user.id, document_id: document.id)
      doc&.update(favorite: false, check_notification: true)
    end
  end   
end
