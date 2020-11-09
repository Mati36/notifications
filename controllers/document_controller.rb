require 'json'
require 'sinatra/base'
require './services/document_service.rb'
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
    @current_user = User.find(id: session[:user_id])
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
    erb :documents
  end

  post '/download_document' do
    doc_id = params['download_document'].to_i 
    begin 
      document = Document_service.download_document(doc_id)
      name_doc = "#{document.id}#{document.format}"
      send_file("public#{document.path}", filename: name_doc) #type: 'Application/octet-stream'
    rescue File_not_found => e 
      redirect back 
    end 
  end

  get '/my_upload_documents' do
    @documents = Document.where(user_id: @current_user.id).order(:created_at).reverse
    @user = User.find_user_id(@current_user.id)
    erb :documents
  end

  get '/doc_view/:id' do
    doc_id =  params[:id].to_i
    Document_service.doc_view(doc_id, @current_user)
    @document = Document.find(id: doc_id)
    @tagged = Tag.where(document_id: doc_id, tag: true)
    @topics = Document_topic.where(document_id: doc_id)
    erb :doc_view, layout: false
  end

  get '/my_tags' do
    @documents = Document.join(Tag.where(user_id: @current_user.id, tag: true), document_id: :id)
    erb :documents
  end

  post '/add_fav' do
    doc_id = params['add_favorite_doc']
    Document_service.add_fav(doc_id, @current_user)
    redirect back
  end

  post '/del_fav' do
    doc_id = params['del_favorite_doc']
    Document_service.del_fav(doc_id, @current_user)
    redirect back
  end

  get '/my_favorites' do
    @documents = Document.join(Tag.where(user_id: @current_user.id, favorite: true), document_id: :id)
    erb :documents
  end

  
end 
