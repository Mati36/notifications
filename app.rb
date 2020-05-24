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
    @session_user = session[:user_id]
    @path = request.path_info
    if !@session_user && @path != '/login' && @path != '/signUp'
      redirect '/login'
    elsif @session_user
      @user = User.find(id: @session_user)
      if (!@user.is_admin && @path == '/save_document')
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
    #@created_date = DateTime.now.strftime("%m/%d/%Y: %T")
    @created_date = DateTime.now.strftime('%Y-%m-%dT%H:%M:%S%z')
    user = User.new(name: params['name'], lastname: params['lastname'], dni: params['dni'], email: params['email'],password: params['pwd'], is_admin:false ,created_at: @created_date)  
    
    if user.valid? 
      if User.all.length == 0
        user.update(is_admin: true)
      end 

      user.save
      redirect '/login'
      
    else
      [401,{},"Usuario no registrado"]
    end 
    
  end

  get '/signUp' do
    if @session_user
      session.clear
    end
    erb :signUp
  end

  get '/log_out' do
    if @session_user
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
      @date = DateTime.now.strftime("%m/%d/%Y: %T")
      
      document = Document.new(title: params["title"], type: params["type"], format:@fileFormat, visibility: true, user_id: session[:user_id], path:"temp", created_at: @date)
        
      if document.valid?
        document.save
        @id = Document.last.id
        @localPath = "#{@directory}#{@id}#{@fileFormat}"
        document.update(path: "/files/#{@id}#{@fileFormat}")
        
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
    if(@session_user)
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
    @documents = Document.where(user_id: @session_user).order(:created_at).reverse
    erb :documents
  end

  get '/my_tags' do 
    #documentos en donde el user esta taggeado

  end  

  

end

