class Tag < Sequel::Model(:documents_users)
  many_to_one :documents
  many_to_one :users

  dataset_module do
    
    def documents_of_user(user_id)
      where(user_id: user_id).order(:created_at)
    end

    def find_document_user(user_id, document_id)
      find(user_id: user_id, document_id: document_id)
    end
  
    def find_document_favorite(user_id, document_id)
      find(user_id: user_id, document_id: document_id, favorite: true)
    end

    def notifications_checked(notifications)
      notifications.each do |notification|
        notification.update(check_notification: true)
      end
    end

    def notifications_count(user_id)
      where(user_id: user_id, check_notification: false).count
    end
  end
end
