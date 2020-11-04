require 'json'
require './services/document_service.rb'
require 'sinatra/base'
require './exceptions/validation_model_error.rb'
require 'date'


class Document_controller < Sinatra::Base

  configure :development, :production do
    set :views, settings.root + '/../views'
  end 

  before do 
    @current_user = User.find(id: session[:user_id])
    @icons = '/images/icons/'
  end

  get '/save_document' do
    @topics = Topic.map(&:to_hash).to_json
    @users  = User.exclude(id: @current_user.id).map(&:to_hash).to_json
    #@current_user = User.find(id: session[:user_id])
    erb :save_document
  end

  post '/save_document' do

    if params[:fileInput]
      file = params[:fileInput] [:tempfile]
      @file_format = File.extname(file)
      @directory = 'public/files/'
      @directory_temp = DateTime.now.strftime('%m/%d/%Y: %T').to_s
      title = params['title'] 
      type_file = params['type'] 
      description = params['description']
      topic = params['select_topic']
      tag = params['tag']

      begin
          document = Document_service.create_document(title, type_file, @file_format, description, @current_user.id, @directory_temp, true, topic, tag, file)  
          redirect '/'
      rescue Validation_model_error => e
        return erb :save_document
      end
    end
  end 
  
  get '/documents' do
    @documents = Document.order(:created_at).reverse
    @user = User.find_user_id(@current_user.id)
    erb :documents
  end

end 
