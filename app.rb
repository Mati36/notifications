# frozen_string_literal: true

class App < Sinatra::Base
  require 'net/http'
  require 'json'
  require 'sinatra'
  require './models/init.rb'
  require 'date'
  require 'sinatra-websocket'
  require 'bcrypt'
  require './controllers/account_controller.rb'
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

      @notifications = Tag.documents_of_user(@current_user.id).reverse

      redirect '/' if @path == '/signUp'
      redirect '/' if !@current_user.is_admin && (@path == '/save_document' || @path == '/change_role')
    end
  end

  use Account_controller

  get '/' do
    Tag.delete_old_views(@current_user)
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

  def ws_msj
    settings.sockets.each do |s|
      notif = Tag.notifications_count(s[:user])
      s[:socket].send(notif.to_s)
    end
  end

  # post '/signUp' do
  #   request.body.rewind
  #   hash = Rack::Utils.parse_nested_query(request.body.read)
  #   params = JSON.parse hash.to_json
  #   user = User.create_user(params['name'], params['lastname'], params['dni'], params['email'], params['pwd'])

  #   if user.valid?
  #     user.save
  #     User.order(user.id)
  #     redirect '/login'
  #   else
  #     redirect '/signUp'
  #   end
  # end

  # get '/signUp' do
  #   erb :signUp
  # end

  # get '/log_out' do
  #   session.clear if @current_user
  #   redirect '/'
  # end

  get '/save_document' do
    @topics = Topic.map(&:to_hash).to_json
    @users  = User.exclude(id: @current_user.id).map(&:to_hash).to_json
    erb :save_document
  end

  post '/save_document' do
    if params[:fileInput]
      file = params[:fileInput] [:tempfile]
      @file_format = File.extname(file)
      @directory = 'public/files/'
      @directory_temp = date_time.to_s

      document = Document.new(title: params['title'], type: params['type'], format: @file_format,
                              description: params['description'], user_id: @current_user.id,
                              path: @directory_temp, visibility: true)

      if document.valid?
        document.save
        @id = Document.last.id
        @local_path = "#{@directory}#{@id}#{@file_format}"
        document.update(path: "/files/#{@id}#{@file_format}")

        tags_user(params['tag'], document)
        Document.add_topics(document, params['select_topic'])
        user_add_notification(document)

        cp(file.path, @local_path)
        File.chmod(0o777, @local_path)
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

  # get '/login' do
  #   if @current_user
  #     redirect '/'
  #   else
  #     erb :login
  #   end
  # end

  # post '/login' do
  #   user = User.find_user_email(params['email'])

  #   if user && User.correct_password(user, params['pwd'])
  #     session[:user_id] = user.id
  #     redirect '/'
  #   else
  #     redirect '/login'
  #   end
  # end

  get '/documents' do
    @documents = Document.order(:created_at).reverse
    @user = User.find_user_id(@current_user.id)
    erb :documents
  end

  get '/doc_view/:id' do
    doc_id =  params[:id].to_i
    @document = Document.find(id: doc_id)
    @tagged = Tag.where(document_id: doc_id, tag: true)
    @topics = Document_topic.where(document_id: doc_id)
    Document.user_cheked_document(@document, @current_user)
    erb :doc_view, layout: false
  end

  get '/my_upload_documents' do
    @documents = Document.where(user_id: @current_user.id).order(:created_at).reverse
    @user = User.find_user_id(@current_user.id)
    erb :documents
  end

  post '/delete_doc' do
    doc_id = params['delete_doc']
    Document.delete_doc(Document.find(id: doc_id)) unless doc_id.nil?
    redirect back
  end

  get '/my_tags' do
    @documents = Document.join(Tag.where(user_id: @current_user.id, tag: true), document_id: :id)
    erb :documents
  end

  get '/profile/:user_id' do
    @user = User.find(id: params[:user_id])
    erb :profile
  end

  get '/edit_profile' do
    erb :edit_profile
  end

  post '/edit_profile' do
    if params[:fileInput]
      file = params[:fileInput][:tempfile]
      @file_format = File.extname(file)
      @localpath_avatar = "/images/avatars/#{@directory}#{@current_user.id}#{@file_format}"
      @current_user.update(avatar_path: @localpath_avatar)
      @directory = "public/#{@localpath_avatar}"

      cp(file.path, @directory)
      File.chmod(0o777, @directory)
    end

    if params['name'].empty? || params['lastname'].empty? || params['email'].empty?
      redirect '/edit_profile'
    else
      @current_user.update(name: params['name'], lastname: params['lastname'],
                           email: params['email'], updated_at: date_time)
      redirect "/profile/#{@current_user.id}"
    end
  end

  get '/change_password' do
    erb :change_password
  end

  post '/change_password' do
    new_pwd = params['pass1']
    rep_new_pwd = params['pass2']
    if User.correct_password(@current_user, params['current_pass'])
      if new_pwd == rep_new_pwd
        @current_user.update(password: User.encrypt_password(new_pwd))
        redirect '/edit_profile'
      else
        redirect '/change_password'
      end
    else
      redirect '/change_password'
    end
  end

  post '/add_topic' do
    new_topic = Topic.new(name: params['topic'])
    new_topic.save if new_topic.valid?
    redirect back
  end

  post '/add_fav' do
    doc_id = params['add_favorite_doc']
    doc = Document.find(id: doc_id)
    Document.user_add_favorite_document(doc, @current_user)
    redirect back
  end

  post '/del_fav' do
    doc_id = params['del_favorite_doc']
    doc = Document.find(id: doc_id)
    Document.user_del_favorite_document(doc, @current_user)
    redirect back
  end

  get '/users_list' do
    @users = User.all
    erb :users_list
  end

  post '/add_admin' do
    user_id = params['addAdmin_id']
    user = User.find_user_id(user_id)
    user&.update(is_admin: true)
    redirect back
  end

  post '/del_admin' do
    user_id = params['delAdmin_id']
    user = User.find_user_id(user_id)
    user&.update(is_admin: false)
    redirect back
  end

  post '/del_user' do
    user_id = params['delete_user_id']
    user = User.find_user_id(user_id)
    if user
      user.remove_all_documents
      user.remove_all_topics
      user.delete
    end
    redirect back
  end

  get '/my_favorites' do
    @documents = Document.join(Tag.where(user_id: @current_user.id, favorite: true), document_id: :id)
    erb :documents
  end

  get '/topic_list' do
    @topics = Topic.all
    erb :topic_list
  end

  post '/delete_topic' do
    topic_id = params['del_topic']
    topic = Topic.find(id: topic_id)
    if topic
      topic.remove_all_documents
      topic.remove_all_users
      topic.delete
    end

    redirect back
  end

  post '/subscription_topic' do
    topic = Topic.find(id: params['sub_topic'])
    @current_user.add_topic(topic)
    redirect back
  end

  post '/del_subscription_topic' do
    topic = Topic.find(id: params['sub_topic'])
    @current_user.remove_topic(topic)
    redirect back
  end

  get '/list_document_topic/:id' do
    @documents = Document.join(Document_topic.where(topic_id: params[:id]), document_id: :id).order(:created_at).reverse
    erb :documents
  end

  get '/notifications' do
    erb :notifications
  end

  post '/notifications' do
    @notifications.each do |notification|
      notification.update(check_notification: true)
    end
  end

  post '/download_document' do
    doc_id = params['download_document'].to_i
    unless doc_id.nil?
      doc = Document.find(id: doc_id)
      unless doc.nil?
        name_doc = "#{doc.id}#{doc.format}"
        send_file("public#{doc.path}", filename: name_doc, type: 'Application/octet-stream')
      end
      redirect back
    end
  end

  def date_time
    DateTime.now.strftime('%m/%d/%Y: %T')
  end

  def tags_user(tag_user, document)
    users = obtain_tags(tag_user)

    users.each do |user_dni|
      if !user_dni.empty? && !@current_user.dni.to_s.eql?(user_dni)
        user = User.find_user_dni(user_dni)
        user.add_document(document) unless Tag.find(user_id: user.id, document_id: document.id)
        Tag.find(user_id: user.id, document_id: document.id).update(tag: true, check_notification: false)
      end
      send_mail(user.email, document, 1) # motive 1: tag an user
    end
    ws_msj
  end

  def user_add_notification(document)
    User.exclude(id: @current_user.id).each do |user|
      user_tagged = Tag.find(user_id: user.id, document_id: document.id)
      next unless !user.nil? && !user_tagged

      document.topics.each do |topic|
        next unless !user_tagged && Subscription.find(user_id: user.id, topic_id: topic.id)

        user.add_document(document)
        send_mail(user.email, document, 2)
        # motive 2: A document was added with a topic that the user is subscribed to
      end
      ws_msj
    end
  end

  def obtain_tags(tags_user)
    tags_user.split('@').reject(&:empty?)
  end

  def send_mail(mail, doc, motive)
    @document = doc
    @motive = motive
    Pony.mail(
      {
        to: mail,
        via: :smtp,
        via_options: {
          address: 'smtp.gmail.com',
          port: '587',
          user_name: 'notificacionesunrc@gmail.com',
          password: 'unrc2020',
          authentication: :plain,
          domain: 'gmail.com'
        },
        subject: 'Sistema de notificaciones UNRC',
        headers: { 'Content-Type' => 'text/html' },
        body: erb(:mail, layout: false)
      }
    )
  end
end
