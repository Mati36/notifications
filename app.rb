class App < Sinatra::Base
  require 'net/http'
  require 'json'
  require 'sinatra'
  require './models/init.rb'
  
  get "/" do
    @hola = "HOLA"
    @hola
  end

  get '/index' do
    erb :index, :locals => {:name => params[:name]}
  end

  post '/index' do
    request.body.rewind 
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 
    user = User.new(name: params['name'], lastname: params['lastname'],email: params['email'],password: params['pwd'] )
    user = User.new('name', 'lastname','email','pwd' )
    #user = User.new(name:'Mati' , lastname: 'lopez' ,email:'email', password: 'pwd')
    if user.save
      #user.last
    else
      [401,{},"no esta guardado papuu"]
    end 
  end

  get '/save_document' do
    erb :index, :locals => {:title => params[:title], :type => params[:type]}
  end
  post '/save_document' do
    #if request.body.size > 0
      request.body.rewind
      hash = Rack::Utils.parse_nested_query(request.body.read)
      params = JSON.parse hash.to_json 
      document = Document.new(title: params["title"], type: params["type"], format: params["format"])
      document.save
      redirect '/'
    #end
    
  end
get '/users' do
    erb :users
  end

  post '/create_user' do
    @name = params[name]
    user = User.new
    user.name = @name
    user.lastname = "aaa"
    user.email = "123@gmail.com"
    user.password = "magic1" 
    user.save
  end

  get '/login' do
    erb :login
  end

  get '/signUp' do
    erb :signUp
  end

end

