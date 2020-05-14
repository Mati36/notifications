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
    set :no_auth_neededs, ['/login']
  end 

  before do 
    request.path_info
    if !session[:user_id]
      redirect '/login'
    elsif session[:user_id]
      @current_user = User.find(id: session[:user_id])
    end
  end


  get "/" do
    "hola"
  end

  post "/" do
    "hola"
  end

  get '/index' do
    erb :index, :locals => {:name => params[:name]}
  end

  post '/signUp' do
    request.body.rewind 
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 
    user = User.new(name: params['name'], lastname: params['lastname'],email: params['email'],password: params['pwd'] )
    
    if user.save
      redirect '/login'
      #user.last
    else
      [401,{},"no esta guardado papuu"]
    end 
  end

  get '/save_document' do
    if sessions[:user.id].present?
      user = User.find(id: session[:user_id])
      user.name
    end  
    erb :save_document
  end

  post '/save_document' do
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 
    document = Document.new(title: params["title"], type: params["type"], format: ["format"], visibility: true)#format: params["format"])
    
    if document.title && document.title != "" && document.type && document.format 
      document.save
      redirect '/'
    else
      redirect '/save_document'
    end 
  end

  get '/users' do
    erb :users
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    user = User.find(email: params['email'])
    if user && user.password == params['pwd']
      session[:user_id] = user.id
      @current_user = User.find(id: session[:user_id])
      redirect '/'
    else
      redirect '/login'
    end
  end

  get '/signUp' do
    erb :signUp
  end

end

