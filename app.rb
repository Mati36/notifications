# frozen_string_literal: true

class App < Sinatra::Base
  require 'net/http'
  require 'json'
  require 'sinatra'
  require './models/init.rb'
  require 'sinatra-websocket'
  require 'bcrypt'
  require './controllers/account_controller.rb'
  require './controllers/document_controller.rb'
  require './controllers/topic_controller.rb'
  require './controllers/user_controller.rb'
  require './controllers/tag_controller.rb'
  include BCrypt
  include FileUtils::Verbose

  configure do
    enable :logging
    enable :sessions
    set :sessions_fail, '/'
    set :sessions_secret, 'inhakiable papuuu'
    set :sessions_fail, true
    set :server, 'thin'
    set :sockets, []
  end

  before do
    @icons = '/images/icons/'
    @current_user = User.find(id: session[:user_id])
    @path = request.path_info
    
    if !@current_user && @path != '/login' && @path != '/signUp'
      redirect '/login'
    elsif @current_user

      @notifications = Tag_service.documents_of_user(@current_user.id).reverse

      redirect '/' if @path == '/signUp'
      redirect '/' if !@current_user.is_admin && (@path == '/save_document' || @path == '/change_role')
    end
  end
  
  use Account_controller
  use Document_controller
  use Topic_controller
  use User_controller
  use Tag_controller

  get '/' do
    Tag_service.delete_old_views(@current_user)
    # Ordena por count y se queda los primeros 10
    @topics = Document_topic.group_and_count(:topic_id).order(:count).reverse.limit(10)
    if !request.websocket?
      erb :index
    else
      request.websocket do |ws|
        ws_open(ws)
      end
    end
  end
   
  def ws_open(ws)
    ws.onopen do
      @connection = { user: @current_user.id, socket: ws }
      settings.sockets << @connection
    end
  end

  def self.ws_msj
    settings.sockets.each do |s|
      notif = Tag_service .notifications_count(s[:user])
      s[:socket].send(notif.to_s)
    end
  end

  def self.send_mail(mail, doc, motive)
    @document = doc
    @motive = motive
    Pony.mail({
        :to => mail, 
        :via => :smtp, 
        :via_options => {
          :address => 'smtp.gmail.com',                     
          :port => '587',
          :user_name => 'notificacionesunrc@gmail.com',
          :password => 'unrc2020',
          :authentication => :plain,
          :domain => "gmail.com",
        },
        :subject => 'Sistema de notificaciones UNRC', 
        :headers => { 'Content-Type' => 'text/html' },
        :body => ERB.new(File.read('views/mail.erb')).result(binding)
        
        
      })
  end

  def self.date_time
    DateTime.now.strftime('%m/%d/%Y: %T')
  end
end
