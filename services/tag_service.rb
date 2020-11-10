class Tag_service
    require './models/user.rb'
    require './models/tag.rb'
    require './models/subscription.rb'
    require './exceptions/validation_model_error.rb'
    require './exceptions/file_not_found.rb'

    def self.checked_notification(notifications) 
        notifications.each do |notification|
            notification.update(check_notification: true)
        end
    end     

    def self.tags_user(tag_user, document,current_user)
        users = obtain_tags(tag_user)
    
        users.each do |user_dni|
          if !user_dni.empty? && !current_user.dni.to_s.eql?(user_dni)
            user = User.find_user_dni(user_dni)
            user.add_document(document) unless Tag.find(user_id: user.id, document_id: document.id)
            Tag.find(user_id: user.id, document_id: document.id).update(tag: true, check_notification: false)
          end
          App.send_mail(user.email, document, 1) # motive 1: tag an user
        end
        App.ws_msj
    end
    
    def self.user_add_notification(document,current_user)
        User.exclude(id: current_user.id).each do |user|
          user_tagged = Tag.find(user_id: user.id, document_id: document.id)
          next unless !user.nil? && !user_tagged
    
          document.topics.each do |topic|
            next unless !user_tagged && Subscription.find(user_id: user.id, topic_id: topic.id)
    
            user.add_document(document)
            App.send_mail(user.email, document, 2)
            # motive 2: A document was added with a topic that the user is subscribed to
          end
          App.ws_msj
        end
    end
    
    def self.obtain_tags(tags_user)
        tags_user.split('@').reject(&:empty?)
    end
    
    def self.notifications_checked(notifications)
        notifications.each do |notification|
          notification.update(check_notification: true)
        end
    end
  
    def self.notifications_count(user_id)
      Tag.where(user_id: user_id, check_notification: false).count
    end

   def self.recent_notification(user_id, all, limit) 
      documents_of_user(user_id)
      .limit(all - limit)
      .offset(limit)
    end   

   def self.delete_old_views(user)
      notification = documents_of_user(user.id)
      limit = 30
      return unless notification.count > limit
      
      recent_notification(user.id, notification.count, limit).each do |n|
        user.remove_document(Document.find(id: n.document_id)) if n.check_notification && !n.tag && !n.favorite
      end
    end

    def self.documents_of_user(user_id)
      Tag.where(user_id: user_id).order(:created_at)
    end

end