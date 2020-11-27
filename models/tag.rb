class Tag < Sequel::Model(:documents_users)
  many_to_one :documents
  many_to_one :users

  dataset_module do

    def find_document_user(user_id, document_id)
      find(user_id: user_id, document_id: document_id)
    end
  
    def find_document_favorite(user_id, document_id)
      find(user_id: user_id, document_id: document_id, favorite: true)
    end

    def users_taggeds(doc_id)
      where(document_id: doc_id, tag: true)
    end
  end
end
