class Topic_service
    require './models/topic.rb'
    require './exceptions/validation_model_error.rb'
    require './exceptions/unexistent_element_error.rb'


    def self.add_topic (topic)
        new_topic = Topic.new(name: topic)
        unless new_topic.valid?
            raise Validation_model_error.new('Tendencia no valida',2)
        end
        new_topic.save if new_topic.valid?
    end

    def self.delete_topic (topic)
        topic = Topic.find(id: topic)
        unless topic
            raise Unexistent_element_error.new('La tendencia no existe',2)
        end
        topic.remove_all_documents
        topic.remove_all_users
        topic.delete
    end

    def self.subscribe_topic (user, topic)
        topic = Topic.find(id: topic)
        unless topic
            raise Unexistent_element_error.new('La tendencia no existe',2)
        end
        unless user
            raise Unexistent_element_error.new('El usuario no existe',2)
        end
        user.add_topic(topic)
    end

    def self.desubscribe_topic (user, topic) 
        topic = Topic.find(id: topic)
        unless topic
            raise Unexistent_element_error.new('La tendencia no existe')
        end
        unless user
            raise Unexistent_element_error.new('El usuario no existe')
        end
        user.remove_topic(topic)
    end
end
