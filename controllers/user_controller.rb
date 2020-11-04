
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

    get '/users' do
        erb :users
    end

    get '/change_password' do
        erb :change_password
    end
    
    get '/users_list' do
        @users = User.all
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
            return erb :change_password
        end
    end       
  
    post '/add_admin' do
        begin
            User_service.add_admin(params['addAdmin_id'])
        rescue Validation_model_error => e
            return redirect back
        end
        redirect back
    end

    post '/del_admin' do
        begin
            User_service.del_admin(params['delAdmin_id'])
        rescue Validation_model_error => e
            return redirect back
        end
        redirect back
    end

    post '/del_user' do
        begin
            User_service.del_user(params['delete_user_id'])
        rescue Validation_model_error => e
            return redirect back
        end
        redirect back
    end
end    