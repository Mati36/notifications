class Tag_controller < Sinatra::Base
    require 'sinatra/base'
    require './services/tag_service.rb'
    require './exceptions/validation_model_error.rb'
    
    configure :development, :production do
        set :views, settings.root + '/../views'
    end 
    
    before do 
        @current_user = User.find(id: session[:user_id])
        @icons = '/images/icons/'
        @notifications = Tag_service.documents_of_user(@current_user.id).reverse if @current_user
    end
   
    get '/notifications' do
        erb :notifications
    end
    
    post '/notifications' do
       Tag_service.checked_notification(@notifications)
    end  
end     