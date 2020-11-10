class Document_service 
  require './models/user.rb'
  require './models/topic.rb'
  require './services/tag_service.rb'
  require './exceptions/validation_model_error.rb'
  require './exceptions/file_not_found.rb'
  include FileUtils::Verbose
  
  def self.create_document(file, title, description, type, current_user, topic, tag)
      file_format = File.extname(file)
      path_temp = " #{App.date_time.to_s}#{file_format}"
      document = Document.new(title: title, type: type, format: file_format,
                              description: description, user_id: current_user.id,
                              path: path_temp, visibility: true)
      unless document.valid?
          raise Validation_model_error.new("Documento no valido")
      end
      document.save
      id = Document.last.id
      local_path = "public/files/#{title}_#{id}#{file_format}"
      document.update(path: "/files/#{title}_#{id}#{file_format}")

      Tag_service.tags_user(tag, document, current_user)
      add_topics(document, topic)
      Tag_service.user_add_notification(document,current_user)

      FileUtils.cp(file.path, local_path)
      File.chmod(0o777, local_path)
  end  
  
  def self.user_cheked_document(document,current_user)
    doc = Tag.find(user_id: current_user.id, document_id: document.id) 
    if doc.nil?
      current_user.add_document(document)
      doc = Tag.find(user_id: current_user.id, document_id: document.id)
    end
    doc.update(checked: true, check_notification: true)
  end

  def self.download_document(doc_id) 
    if doc_id.nil?
      raise File_not_found.new("Archivo no encontrado")
    else  
      doc = Document.find(id: doc_id)
      if doc.nil?
        raise File_not_found.new("Archivo inexistente") 
      else  
        doc
      end  
    end
  end 

  def self.add_fav (doc_id,current_user)
    doc = Document.find(id: doc_id) 
    if doc.nil?
      raise File_not_found.new("Archivo inexistente")
    end  
    user_add_favorite_document(doc, current_user)
  end

  def self.del_fav (doc_id,current_user)
    doc = Document.find(id: doc_id)
    if doc.nil?
      raise File_not_found.new("Archivo inexistente")
    end  
    user_del_favorite_document(doc, current_user)
  end

  
  def self.doc_view (document, current_user)
    user_cheked_document(document, current_user) unless document
  end

  def self.delete_doc(doc_id)
    document = Document.find(id: doc_id)
    unless document
      raise File_not_found.new("Archivo inexistente")
    end   
    document.update(visibility: false) 
  end

  def self.user_add_favorite_document(document,current_user)
    doc = Tag.find(user_id: current_user.id, document_id: document.id)
    if doc.nil?
      current_user.add_document(document)
      doc = Tag.find(user_id: current_user.id, document_id: document.id)
    end
    doc.update(favorite: true, check_notification: true)
  end

  def self.user_del_favorite_document(document,current_user) 
    doc = Tag.find(user_id: current_user.id, document_id: document.id)
    doc&.update(favorite: false, check_notification: true)
  end

  def self.add_topics(document, topics)
    topics = topics.split('#').reject(&:empty?)
    topics.each do |topic_name|
      next if topic_name.empty?

      topic = Topic.find(name: topic_name)
      document.add_topic(topic) unless Document_topic.find(document_id: document.id, topic_id: topic.id)
    end
  end
end


                    