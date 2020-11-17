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

  register Sinatra::Flash

  get '/save_document' do
    @topics = Topic.map(&:to_hash).to_json
    @users  = User.exclude(id: @current_user.id).map(&:to_hash).to_json
    erb :save_document
  end

  post '/save_document' do

    if params[:fileInput]
      file = params[:fileInput] [:tempfile]
      @directory = 'public/files/'
      title = params['title'] 
      type_file = params['type'] 
      description = params['description']
      topic = params['select_topic']
      tag = params['tag']

      begin
          document = Document_service.create_document(file, title, description, type_file, @current_user, topic, tag)  
          redirect '/'
      rescue Sequel::ValidationFailed => e
        flash.now[:error_message] = e.message
        return erb :save_document
      end
    end
  end 
  
  get '/documents' do
    @documents = Document.order(:created_at).reverse
    flash.now[:error_message] = ''
    erb :documents
  end

  post '/download_document' do
    doc_id = params['download_document'].to_i 
    begin 
      document = Document_service.download_document(doc_id)
      name_doc = "#{document.title}_#{document.id}#{document.format}"
      send_file("public#{document.path}", filename: name_doc) #type: 'Application/octet-stream'
    rescue File_not_found => e
      flash.now[:error_message] = e.message 
      redirect back 
    end 
  end

  get '/my_upload_documents' do
    @documents = Document.where(user_id: @current_user.id).order(:created_at).reverse
    @user = User.find_user_id(@current_user.id)
    flash.now[:error_message] = ''
    erb :documents
  end

  get '/doc_view/:id' do
    doc_id =  params[:id].to_i
    @document = Document.find(id: doc_id)
    @tagged = Tag.users_taggeds(doc_id)
    @topics = Document_topic.where(document_id: doc_id)
    begin
      Document_service.doc_view(@document, @current_user)
      erb :doc_view, layout: false
    rescue File_not_found => e
      flash.now[:error_message] = e.message
      redirect back
    end
  end

  get '/my_tags' do
    @documents = Document.join(Tag.where(user_id: @current_user.id, tag: true), document_id: :id)
    flash.now[:error_message] = ''
    erb :documents
  end

  post '/add_fav' do
    doc_id = params['add_favorite_doc']
    Document_service.add_fav(doc_id, @current_user)
    flash.now[:error_message] = ''
    redirect back
  end

  post '/del_fav' do
    doc_id = params['del_favorite_doc']
    Document_service.del_fav(doc_id, @current_user)
    flash.now[:error_message] = ''
    redirect back
  end

  get '/my_favorites' do
    @documents = Document.join(Tag.where(user_id: @current_user.id, favorite: true), document_id: :id)
    flash.now[:error_message] = ''
    erb :documents
  end

  post '/delete_doc' do
    doc_id = params['delete_doc']
    begin
      Document_service.delete_doc(doc_id) 
      redirect back
    rescue File_not_found => e 
      flash.now[:error_message] = e.message
      redirect back
    end  
  end

  get '/list_document_topic/:id' do
    @documents = Document.join(Document_topic.where(topic_id: params[:id]), document_id: :id).order(:created_at).reverse
    flash.now[:error_message] = ''
    erb :documents
  end
  
end 
