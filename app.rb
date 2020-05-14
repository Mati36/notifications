require 'sinatra/base'
require "sinatra/config_file"
require './models/user.rb'

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
    erb :save_document
  end

  post '/save_document' do
    request.body.rewind
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 
    document = Document.new(title: params["title"], type: params["type"], format: ["format"])#format: params["format"])
    
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
    if user.password == params['pwd']
      sessions[:user.name] = user.name
      sessions[:user.lastname] = user.lastname      
      sessions[:user.dni] = user.dni
      redirect '/'
    else
      redirect '/login'
    end
  end

  get '/signUp' do
    erb :signUp
  end

end

