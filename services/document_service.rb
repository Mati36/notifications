class Document_service 
 
  require './models/user.rb'
  require './models/topic.rb'
  require './exceptions/validation_model_error.rb'
  include FileUtils::Verbose
  
  def self.create_document(title, type, file_format, description, user_id, path, visibility, topic, tag, file)
      @directory = 'public/files/'
      document = Document.new(title: title, type: type, format: file_format,
                              description: description, user_id: user_id,
                              path: path, visibility: visibility)
      unless document.valid?
          raise Validation_model_error.new("Documento no valido")
      end
      document.save
      id = Document.last.id
      @local_path = "#{@directory}#{id}#{file_format}"
      document.update(path: "/files/#{id}#{file_format}")

      #App.tags_user(tag, document)
      Document.add_topics(document, topic)
      #App.user_add_notification(document)

      FileUtils.cp(file.path, @local_path)
      File.chmod(0o777, @local_path)
  end     
end


                    