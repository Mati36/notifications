class App < Sinatra::Base
  require 'net/http'
  require 'json'
  require 'sinatra'
  require './models/init.rb'
  require 'date'
  require 'sinatra-websocket'
  require 'bcrypt'
  include BCrypt
  include FileUtils::Verbose
  
  configure do 
    enable :logging
    enable :sessions
    set :sessions_fail, '/'
    set :sessions_secret, "inhakiable papuuu"
    set :sessions_fail, true
    set :server, 'thin'
    set :sockets, []
  end 

  before do 
    @icons = "/images/icons/"
    
    @current_user = User.find(id: session[:user_id])
    @path = request.path_info
    
    if !@current_user && @path != '/login' && @path != '/signUp'
      redirect '/login'
    elsif @current_user
      
      @notifications = get_notification
      
     if (@path == '/signUp')
        redirect '/'
      end  
      if (!@current_user.is_admin && (@path == '/save_document' || @path == '/change_role' || @path == '/edit_document/:id'))
        redirect '/'
      end  
    end
  end

  get "/" do
    @topics = Document_topic.group_and_count(:topic_id).order(:count).reverse.limit(10) #Ordena por count y se queda los primeros 10
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
      @connection = {socket: ws}
      settings.sockets << @connection
    end
  end  

  def ws_msj(msg)
    EM.next_tick { settings.sockets.each { |s| s[:socket].send(msg.to_s)} }
  end  

  post '/signUp' do
    request.body.rewind 
    hash = Rack::Utils.parse_nested_query(request.body.read)
    params = JSON.parse hash.to_json 
    user =  create_user(params['name'],params['lastname'],params['dni'],params['email'],params['pwd'])  
    
    if user.valid? 
      user.save
      User.order(user.id)
      redirect '/login'
    else
      [401,{},"Usuario no registrado"]
    end 
  end

  get '/signUp' do
   erb :signUp
  end

  get '/log_out' do
    if @current_user
      session.clear
    end
    redirect '/'
  end

  get '/save_document' do 
    @topics = Topic.map{|x| x.to_hash}.to_json
    @users  = User.exclude(id: @current_user.id).map{|x| x.to_hash}.to_json
    erb :save_document
  end

  post '/save_document' do
   
   if(params[:fileInput])
      file = params[:fileInput] [:tempfile]
      @fileFormat = File.extname(file)
      @directory = "public/files/"
      @directory_temp = "#{date_time}"
      
      document = Document.new(title: params["title"], type: params["type"], format: @fileFormat,
                              description: params["description"], user_id: @current_user.id, 
                              path: @directory_temp, visibility: true)

      if document.valid?
        document.save
        @id = Document.last.id
        @localPath = "#{@directory}#{@id}#{@fileFormat}"
        document.update(path: "/files/#{@id}#{@fileFormat}")

        tags_user_document(params["tag"],document)
        document_add_topic(document, params["select_topic"])
        user_add_notification(document)
        
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
    if @current_user
      redirect '/'
    else
      erb :login
    end
  end

  post '/login' do
    user = find_user_email(params['email'])
    
    if user && User.correct_password(user,params['pwd'])  
      session[:user_id] = user.id
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

  post '/choose_type' do
    type = params["type"]
    if type == "Act"
      @documents = Document.where(type: "Act").order(:created_at).reverse
    elsif  type == "Resolution"
      @documents = Document.where(type: "Resolution").order(:created_at).reverse
    else
      @documents = Document.order(:created_at).reverse
    end  
    erb :documents
  end  

  get '/doc_view/:id' do
    doc_id =  params[:id].to_i
    @document = Document.find(id: doc_id)
    @tagged = Tag.where(document_id: doc_id, tag: true)
    @topics = Document_topic.where(document_id: doc_id)
    user_cheked_document(@document)
    erb :doc_view, :layout => false 
  end

  get '/my_upload_documents' do
    @documents = Document.where(user_id: @current_user.id).order(:created_at).reverse
    @user = find_user_id(@current_user.id)
    erb :documents
  end

  post '/delete_doc' do 
    doc_id = params["delete_doc"] 
    if !doc_id.nil?
      delete_doc(Document.find(id: doc_id))
    end  
   redirect '/my_upload_documents'
  end

  get '/my_tags' do 
    @documents = Document.join(Tag.where(user_id: @current_user.id, tag: true),document_id: :id)
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

    if(params[:fileInput])
      file = params[:fileInput][:tempfile]
      @fileFormat = File.extname(file)
      @localpath_avatar = "/images/avatars/#{@directory}#{@current_user.id}#{@fileFormat}"
      @current_user.update(avatar_path: @localpath_avatar)
      @directory = "public/#{@localpath_avatar}"

      cp(file.path, @directory)
      File.chmod(0777, @directory)
    end   

    if params["name"].empty? || params["lastname"].empty? || params["email"].empty?
      redirect '/edit_profile'
    else
      @current_user.update(name: params["name"], lastname: params["lastname"], email: params["email"], updated_at: date_time)
      redirect "/profile/#{@current_user.id}" 
    end  
  end  

  get '/change_password' do
    erb :change_password
  end  

  post '/change_password' do 
    new_pwd = params["pass1"] 
    rep_new_pwd = params["pass2"]
    if User.correct_password(@current_user, params["current_pass"]) 
      if new_pwd == rep_new_pwd 
        @current_user.update( password: User.encrypt_password(new_pwd) )
        redirect '/edit_profile'
      else
        redirect '/change_password'
      end  
    else
      redirect '/change_password'
    end    
  end  

  get '/add_topic' do
    erb :new_topic
  end  

  post '/add_topic' do
    new_topic = Topic.new(name: params["topic"])
    if new_topic.valid?
      new_topic.save
      redirect '/'
    else
      redirect '/add_topic'
    end      
  end 

  post '/add_fav' do
    doc_id = params["add_favorite_doc"]
    doc = Document.find(id: doc_id )
    user_add_favorite_document(doc)
    redirect back
  end  

  post '/del_fav' do
    doc_id = params["del_favorite_doc"]
    doc = Document.find(id: doc_id)
    user_del_favorite_document(doc)
    redirect back 
  end  

  get '/change_role/:action' do 
    @act = params[:action]
    erb :change_role 
  end

  post '/change_role/:action' do
    action = params[:action]
    user_tag = get_tags(params['tag']).first
    if user_tag.oct == 0
      @user = find_user_email(user_tag)
    elsif user_tag.length >= 8 
      @user =  find_user_dni(user_tag.to_i)
    end
    

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

  get '/users_list' do
    @users = User.all
    erb :users_list
  end 

  post '/add_admin' do
    user_id = params["addAdmin_id"]
    user = find_user_id(user_id)
    if user 
      user.update(is_admin: true)
    end   
    redirect back
  end 

  post '/del_admin' do
    user_id = params["delAdmin_id"]
    user = find_user_id(user_id)
    if user 
      user.update(is_admin: false)
    end 
    redirect back
  end 

  post '/del_user' do
    user_id = params["delete_user_id"]
    user = find_user_id(user_id)
    if user 
      user.remove_all_documents
      user.remove_all_topics
      user.delete
    end 
    redirect back  
  end 
  

  get '/my_favorites' do 
    @documents = Document.join(Tag.where(user_id: @current_user.id, favorite: true),document_id: :id)
    erb :documents
  end

  get '/topic_list' do
    @topics = Topic.all
    erb :topic_list
  end   

  post '/delete_topic' do
    topic_id = params["del_topic"]
    topic = Topic.find(id: topic_id)
    if topic
      topic.remove_all_documents
      topic.remove_all_users
      topic.delete
    end  
    
    redirect back
  end  

  post '/subscription_topic' do
    topic = Topic.find(id: params["sub_topic"])
    @current_user.add_topic(topic) 
    redirect back
  end  

  post '/del_subscription_topic' do 
    topic = Topic.find(id: params["sub_topic"])
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

  get '/edit_document/:id' do 
    erb :edit_document
  end

  post '/edit_document/:id' do
    doc_id =  params[:id].to_i
    @document = Document.find(id: doc_id)
    if params["title"].empty? || params["description"].empty?
      path = request.path_info
      redirect path
    else
      @document.update(title: params["title"], description: params["description"])
      newTags = params["newTags"]
      tags_user_document(newTags, @document)
      redirect '/doc_view/'+doc_id.to_s
    end 
  end

  post '/download_document' do
    doc_id = params["download_document"].to_i 
    if !doc_id.nil?
      doc = Document.find(id: doc_id)
      if !doc.nil? 
        name_doc = "#{doc.id}#{doc.format}"
        send_file("#{"public"}#{doc.path}", :filename => name_doc, :type => 'Application/octet-stream')
        redirect back
      else
        redirect back
      end    
    end  
  end

 # metodos 

  def date_time 
   return DateTime.now.strftime("%m/%d/%Y: %T")
  end  

  # este metodo taggea a los usuarios con el documento
  def tags_user_document(tags_user, document) 
    users = get_tags(tags_user)
    users.each do |user_dni|
     
      if !user_dni.empty?
        user = find_user_dni(user_dni)
        if !Tag.find(user_id: user.id, document_id: document.id)
          user.add_document(document)
        end
        Tag.find(user_id: user.id, document_id: document.id).update(tag: true, check_notification: false)
        ws_msj(get_notification_count(user.id)) 
      end  
    end
  end  

  def user_add_notification(document)
    User.exclude(id: @current_user.id).each do |user|
      if !user.nil? && !Tag.find(user_id: user.id, document_id: document.id)
        document.topics.each do |topic|
          if !find_document_user(user.id, document.id) && Subscription.find(user_id: user.id, topic_id: topic.id)
            user.add_document(document)
            ws_msj(get_notification_count(user.id)) 
          end
        end   
      end  
    end
  end 

  def user_cheked_document(document)
    doc = find_document_user(@current_user.id, document.id)
    if doc.nil?
      @current_user.add_document(document)
      doc = find_document_user(@current_user.id, document.id)
    end 
      doc.update(checked: true, check_notification: true)
  end 

  def user_add_favorite_document(document)
    doc = find_document_user(@current_user.id, document.id)
    if doc.nil?
      @current_user.add_document(document)
      doc = find_document_user(@current_user.id, document.id)
    end 
      doc.update(favorite: true,check_notification: true)
  end 

  def user_del_favorite_document(document)
    doc = find_document_user(@current_user.id, document.id)
    if !doc.nil?
      doc.update(favorite: false,check_notification: true)
      if !doc.tag && !doc.checked && doc.check_notification
        @current_user.remove_document(document)
      end 
    end 
  end 

  def find_document_user(user_id, document_id)
    return Tag.find(user_id: user_id, document_id: document_id)
  end
 
  def find_document_favorite(user_id, document_id)
     return Tag.find(user_id: user_id, document_id: document_id,favorite: true) 
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

  def get_tags(tags_user)
    return tags_user.split('@').reject { |user| user.empty? }
  end  

  def user_subscription(topic)
    @current_user.add_topic(topic)
  end 

  def document_add_topic(document,topics_document)
  
    topics = topics_document.split('#').reject { |topic| topic.empty? }
    topics.each do |topic_name|
     
      if !topic_name.empty?
        topic = Topic.find(name: topic_name);
        if !Document_topic.find(document_id: document.id,topic_id: topic.id)
          document.add_topic(topic)
        end
      end  
    end

  end 
  
  def create_user(name,lastname,dni,email,password)
    user = User.new(name: name, lastname: lastname, dni: dni, 
                     email: email, password: User.encrypt_password(password))  

    if (User.all.length <= 0)
      user.update(is_admin: true)
    end 
    
    return user
  end  

  def notifications_checked(notifications)
    notifications.each do |notification|
      notification.update(check_notification: true)
    end
  end  

  def notification_count 
    
    get_notification.each do |notif|
      if !notif.check_notification
          @newNotif = @newNotif + 1
      end
    end
    return @newNotif
  end  

  def get_notification
    Tag.where(user_id: @current_user.id).order(:created_at).reverse
  end  

  def get_notification_count(user_id)
    Tag.where(user_id: user_id, check_notification: false).count
  end
  
end