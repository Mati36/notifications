class Topic_service
    require './models/topic.rb'
    require './exceptions/validation_model_error.rb'

    def self.add_topic (topic)
        new_topic = Topic.new(name: topic)
        unless new_topic.valid?
            raise Validation_model_error.new("Tendencia no valida")
        end
        new_topic.save if new_topic.valid?
    end

    def self.delete_topic (topic)
        topic = Topic.find(id: topic)
        if topic
            topic.remove_all_documents
            topic.remove_all_users
            topic.delete
        end
    end

end     