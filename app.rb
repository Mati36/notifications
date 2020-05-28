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
    @current_user = session[:current_user]
    @path = request.path_info
  
    if !@current_user && @path != '/login' && @path != '/signUp'
      redirect '/login'
    elsif @current_user
      if (!@current_user.is_admin && (@path == '/save_document' || @path == '/change_role'))
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
    if @current_user.id
      session.clear
    end
    erb :signUp
  end

  get '/log_out' do
    if @current_user.id
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
      
      document = Document.new(title: params["title"], type: params["type"], format:@fileFormat, visibility: true, user_id: @current_user.id, path:@directory_temp, created_at: date_time)
     
      if document.valid?
        document.save
        @id = Document.last.id
        @localPath = "#{@directory}#{@id}#{@fileFormat}"
        document.update(path: "/files/#{@id}#{@fileFormat}")
        
        tags_user(params["tag"],document)
        dir_create(@directory)
       
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
    if(@current_user)
      redirect '/'
    else
      erb :login
    end
  end

  post '/login' do
    user = find_user_email(params['email'])
    
    if user && user.password == params['pwd']
      session[:current_user] = user
      redirect '/'
    else
      redirect '/login'
    end
  end

  get '/documents' do
    @documents = Document.order(:created_at).reverse
    @user = find_user_id(@current_user.id)
    erb :documents
  end

  get '/doc_view/:id' do
    @document = Document.find(id: params[:id])
    erb :doc_view, :layout => false 
  end

  get '/my_upload_documents' do
    @documents = Document.where(user_id: @current_user.id).order(:created_at).reverse
    
    @user = find_user_id(@current_user.id)
    erb :documents
  end

  get '/delete_doc/:document' do
    if params[:document] != nil
      delete_doc(Document.find(id: params[:document]))
      
    end  
   redirect '/my_upload_documents'
  end

  get '/my_tags' do 
    @documents = Document.join(Tag.where(user_id: @current_user.id),document_id: :id)
    erb :documents
  end  

  get '/change_role/:action' do 
    @act = params[:action]
    erb :change_role 
  end

  post '/change_role/:action' do
    action = params[:action]
    
    user_tag = params['tag'].split('@').reject { |user| user.empty? }.first
    if user_tag.oct == 0
      @user = find_user_email(user_tag)
      logger.info(@user != nil) 
    elsif user_tag.length >= 8 
      @user =  find_user_dni(user_tag.to_i)
    end
    #creo que el error es cuando agregas uno que ta esta
    if @user && @current_user.id != @user.id 
      if action == 'delete_admin' && @user.is_admin && User.where(is_admin: true).all.length > 1
        @user.update(is_admin: false, updated_at: date_time)
      elsif action == 'add_admin'
        @user.update(is_admin: true, updated_at: date_time)
      end
        redirect '/'
    else 
      redirect '/change_role'  
    end  
  end   

  get '/profile' do 
    erb :profile
  end  

  get '/edit_profile' do
    erb :edit_profile
  end  

  post '/edit_profile' do
    if params["name"].empty? || params["lastname"].empty? || params["email"].empty?
      redirect '/edit_profile'
    else
      @current_user.update(name: params["name"], lastname: params["lastname"], email: params["email"], updated_at: date_time)
      redirect '/' 
    end  
  end  

 # metodos 

  def date_time 
   return DateTime.now.strftime("%m/%d/%Y: %T")
  end  
 
  # este mertodo taggea a los usuarios con el documento
  def tags_user(tags_user, document) 
    users = tags_user.split('@')
    users.each do |user_dni|
     
      if !user_dni.empty?
        user = find_user_dni(user_dni)
        user.add_document(document) 
      end  
    end
  end  

  def delete_doc(document)
     if document
      document.update(visibility: false)  
     end 
  end  

  def find_user_id(current_id)
    return User.find(id: current_id)
  end  
  
  def find_user_dni(current_dni)
    return User.find(dni: current_dni)
  end 

  def find_user_email(current_email)
    return User.find(email: current_email)
  end 

  def dir_create(directory)
    if !Dir.exist?(directory)
      Dir.mkdir(directory)
      File.chmod(0777, directory)
    end
  end  
  
  def consola(ms,var)
    logger.info("#{ms} #{var}")
  end  
end

