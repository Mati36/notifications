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
   
  def self.ws_open(ws)
    ws.onopen do
      @connection = { user: @current_user.id, socket: ws }
      settings.sockets << @connection
    end
  end

  def self.ws_msj
    settings.sockets.each do |s|
      notif = Tag.notifications_count(s[:user])
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

  #get '/list_document_topic/:id' do
  #  @documents = Document.join(Document_topic.where(topic_id: params[:id]), document_id: :id).order(:created_at).reverse
  #  erb :documents
  #end

  # get '/notifications' do
  #   erb :notifications
  # end

  # post '/notifications' do
  #   @notifications.each do |notification|
  #     notification.update(check_notification: true)
  #   end
  # end

  def self.date_time
    DateTime.now.strftime('%m/%d/%Y: %T')
  end

  # def tags_user(tag_user, document)
  #   users = obtain_tags(tag_user)

  #   users.each do |user_dni|
  #     if !user_dni.empty? && !@current_user.dni.to_s.eql?(user_dni)
  #       user = User.find_user_dni(user_dni)
  #       user.add_document(document) unless Tag.find(user_id: user.id, document_id: document.id)
  #       Tag.find(user_id: user.id, document_id: document.id).update(tag: true, check_notification: false)
  #     end
  #     send_mail(user.email, document, 1) # motive 1: tag an user
  #   end
  #   ws_msj
  # end

  # def user_add_notification(document)
  #   User.exclude(id: @current_user.id).each do |user|
  #     user_tagged = Tag.find(user_id: user.id, document_id: document.id)
  #     next unless !user.nil? && !user_tagged

  #     document.topics.each do |topic|
  #       next unless !user_tagged && Subscription.find(user_id: user.id, topic_id: topic.id)

  #       user.add_document(document)
  #       send_mail(user.email, document, 2)
  #       # motive 2: A document was added with a topic that the user is subscribed to
  #     end
  #     ws_msj
  #   end
  # end

  # def obtain_tags(tags_user)
  #   tags_user.split('@').reject(&:empty?)
  # end
  
end
