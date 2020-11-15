
class User_controller < Sinatra::Base
    require './services/user_service.rb'
    require 'sinatra/base'
    require './exceptions/validation_model_error.rb'
    
    configure :development, :production do
       set :views, settings.root + '/../views'
    end
    
    before do
       @current_user = User.find_user_id(session[:user_id])
       @icons = '/images/icons/'
    end    

    register Sinatra::Flash

    get '/users' do
        erb :users
    end

    get '/change_password' do
        erb :change_password
    end
    
    get '/users_list' do
        @users = User.all
        flash[:error_message] = ''
        erb :users_list
    end

    post '/change_password' do
        new_pwd = params['pass1']
        rep_new_pwd = params['pass2']
        current_pass = params['current_pass']
        logger.info("user #{@current_user}")
        begin
            User_service.change_password(@current_user,current_pass,new_pwd,rep_new_pwd)
            redirect '/edit_profile'
        rescue Validation_model_error => e
            flash[:error_message] = e.message
            return erb :change_password
        end
    end       
  
    post '/add_admin' do
        begin
            User_service.add_admin(params['addAdmin_id'])
        rescue Unexistent_element_error => e
            flash[:error_message] = e.message
            return redirect back
        end
        redirect back
    end

    post '/del_admin' do
        begin
            User_service.del_admin(params['delAdmin_id'])
        rescue Unexistent_element_error => e
            flash[:error_message] = e.message
            return redirect back
        end
        redirect back
    end

    post '/del_user' do
        begin
            User_service.del_user(params['delete_user_id'])
        rescue Validation_model_error => e
            flash[:error_message] = e.message
            return redirect back
        end
        redirect back
    end

    get '/profile/:user_id' do
        @user = User.find(id: params[:user_id])
        erb :profile
      end
    
    get '/edit_profile' do
        flash[:error_message] = ''
        erb :edit_profile
    end

    post '/edit_profile' do
        file = params[:fileInput][:tempfile] if params[:fileInput] 
        begin
            User_service.edit_profile(@current_user,file,params['name'],params['lastname'],params['email'])
            redirect "/profile/#{@current_user.id}"
        rescue Sequel::ValidationFailed => e
            flash[:error_message] = e.message
            return redirect back
        end
    end    
end    