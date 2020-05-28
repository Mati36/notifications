class App < Sinatra::Base
  require 'net/http'
  require 'json'
  require 'sinatra'
  require './models/init.rb'
  require 'date'
  include FileUtils::Verbose

  configure do 
    enable :logging
    enable :sessions
    set :sessions_fail, '/'
    set :sessions_secret, "inhakiable papuuu"
    set :sessions_fail, true
  end 

  before do 
    @session_user_id = session[:user_id]
    @path = request.path_info
    if !@session_user_id && @path != '/login' && @path != '/signUp'
      redirect '/login'
    elsif @session_user_id
      @user = User.find(id: @session_user_id)
      if (!@user.is_admin && (@path == '/save_document' || @path == '/change_role'))
        redirect '/'
      end  
    end
  end

  get "/" do
    erb :index
  end

  post '/signUp' do
    request.body.rewind 
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 
    user = User.new(name: params['name'], lastname: params['lastname'], dni: params['dni'], email: params['email'],password: params['pwd'], is_admin:false ,created_at: date_time)  
    
    if user.valid? 
      if User.all.length == 0
        user.update(is_admin: true)
      end 
      user.save
      User.order(user.id)

      redirect '/login'
      
    else
      [401,{},"Usuario no registrado"]
    end 
  end

  get '/signUp' do
    if @session_user_id
      session.clear
    end
    erb :signUp
  end

  get '/log_out' do
    if @session_user_id
      session.clear
    end
    redirect '/'
  end

  get '/save_document' do 
    erb :save_document
  end

  post '/save_document' do
    if(params[:fileInput])
      file = params[:fileInput] [:tempfile]
      @fileFormat = File.extname(file)
      @directory = "public/files/"
      @directory_temp = "#{date_time}"
      
      document = Document.new(title: params["title"], type: params["type"], format:@fileFormat, visibility: true, user_id: session[:user_id], path:@directory_temp, created_at: date_time)
     
      if document.valid?
        document.save
        @id = Document.last.id
        @localPath = "#{@directory}#{@id}#{@fileFormat}"
        document.update(path: "/files/#{@id}#{@fileFormat}")
        
        tags_user(params["tag"],document)
        
        if !Dir.exist?(@directory)
          Dir.mkdir(@directory)
          File.chmod(0777, @directory)
        end
        
        cp(file.path, @localPath)
        File.chmod(0777, @localPath)
        redirect '/'
      
      else 
       redirect '/save_document'
      end 
     
    else
      redirect '/save_document'
    end 
  end

  get '/users' do
    erb :users
  end

  get '/login' do
    if(@session_user_id)
      redirect '/'
    else
      erb :login
    end
  end

  post '/login' do
    user = User.find(email: params['email'])
    
    if user && user.password == params['pwd']
      session[:user_id] = user.id
      session[:user_name] = user.name
      session[:user_is_admin] = user.is_admin
      redirect '/'
    else
      redirect '/login'
    end
  end

  get '/documents' do
    @documents = Document.order(:created_at).reverse
    erb :documents
  end

  get '/doc_view/:id' do
    @document = Document.find(id: params[:id])
    erb :doc_view, :layout => false 
  end

  get '/my_upload_documents' do
    @documents = Document.where(user_id: @session_user_id).order(:created_at).reverse
    
    @user =User.find(id: @session_user_id)
    erb :documents
  end

  get '/delete_doc/:document' do
    if params[:document] != nil
      delete_doc(Document.find(id: params[:document]))
      
    end  
   redirect '/my_upload_documents'
  end

  get '/my_tags' do 
    @documents = Document.join(Tag.where(user_id: @session_user_id),document_id: :id)
    erb :documents
  end  

  get '/change_role' do 
    erb :change_role
  end

  post '/change_role' do
    user_tag = params['tag'].split('@').reject { |user| user.empty? }.first
       

    if user_tag.oct == 0
      logger.info(user_tag) 
      @user = User.find(email: user_tag)
      logger.info(@user != nil) 
    elsif user_tag.length >= 8 
      @user = User.find(dni: user_tag.to_i)
    end
    
    if @user && @session_user_id != @user.id 
      if @user.is_admin && User.where(is_admin: true).all.length > 1
        @user.update(is_admin: false, updated_at: date_time)
      else
        @user.update(is_admin: true, updated_at: date_time)
      end
        redirect '/'
    else 
      redirect '/change_role'  
    end  
  end   

  get '/profile' do 
    @user =User.find(id: @session_user_id)
    erb :profile
  end  

  get '/edit_profile' do
    @user =User.find(id: @session_user_id) 
    erb :edit_profile
  end  

  post '/edit_profile' do
    @user =User.find(id: @session_user_id)
    if params["name"] == '' || params["lastname"] == '' || params["email"] == ''
      redirect '/edit_profile'
    else
      @user.update(name: params["name"], lastname: params["lastname"], email: params["email"], updated_at: date_time)
      redirect '/' 
    end  
  end  

 # metodos 

  def date_time 
   return DateTime.now.strftime("%m/%d/%Y: %T")
  end  

  def tags_user(tags_user, document) 
    users = tags_user.split('@')
    users.each do |user_dni|
     
      if !user_dni.empty?
        user = User.find(dni: user_dni)
        user.add_document(document) 
      end  
    end
  end  

  def delete_doc(document)
     if document
      document.update(visibility: false)  
     end 
  end  

end

