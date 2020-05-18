class App < Sinatra::Base
  require 'net/http'
  require 'json'
  require 'sinatra'
  require './models/init.rb'
  include FileUtils::Verbose

  configure do 
    enable :logging
    enable :sessions
    set :sessions_fail, '/'
    set :sessions_secret, "inhakiable papuuu"
    set :sessions_fail, true
  end 

  before do 
    @path = request.path_info
    #logger.info(session[:user_id])
    #logger.info(session[:user_name])
    if !session[:user_id] && @path != '/login' && @path != '/signUp'
      redirect '/login'
    elsif session[:user_id]
      @user = User.find(id: session[:user_id])
      #logger.info(@user.name);
    end
  end

  get "/" do
    @user = User.find(id: session[:user_id])
    "Welcome " + @user.name
  end

  post '/signUp' do
    request.body.rewind 
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 
    user = User.new(name: params['name'], lastname: params['lastname'], dni: params['dni'], email: params['email'],password: params['pwd'] )
    
    if user.save
      redirect '/login'
      #user.last
    else
      [401,{},"no esta guardado papuu"]
    end 
  end

  get '/signUp' do
    if session[:user_id]
      session.clear
    end
    erb :signUp
  end

  get '/save_document' do 
    erb :save_document
  end

  post '/save_document' do
   
    file = params[:fileInput] [:tempfile]
    @fileName = params["title"]
    @fileFormat = File.extname(file)
   
    document = Document.new(title: @fileName, type: params["type"], format:@fileFormat, visibility: true, user_id: session[:user_id])#format: params["format"])

    if document.title && document.title != "" && document.type && document.format && document.format != ""
      document.save
      cp(file.path, "public/".concat(@fileName.concat(@fileFormat)))
      redirect '/'
    else
      redirect '/save_document'
    end 
  end

  get '/users' do
    erb :users
  end

  get '/login' do
    if(session[:user_id])
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
      session[:user_role] = user.role
      logger.info(session[:user_role])
      @current_user = User.find(id: session[:user_id])
      redirect '/'
    else
      redirect '/login'
    end
  end

end

