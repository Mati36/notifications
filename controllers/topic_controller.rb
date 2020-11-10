require 'json'
require './services/topic_service.rb'
require 'sinatra/base'
require './exceptions/validation_model_error.rb'
require './exceptions/unexistent_element_error.rb'

class Topic_controller < Sinatra::Base
  configure :development, :production do
    set :views, settings.root + '/../views'
  end

  before do
    @current_user = User.find(id: session[:user_id])
    @icons = '/images/icons/'
  end

  post '/add_topic' do
    begin
      Topic_service.add_topic(params['topic'])
      redirect back
    rescue Validation_model_error => e
      @topics = Topic.all
      erb :topic_list, :locals => {:error_message => e.message}
      redirect back
    end
  end

  get '/topic_list' do
      @topics = Topic.all
      erb :topic_list 
  end

  post '/delete_topic' do
    begin
      Topic_service.delete_topic(params['del_topic'])
      redirect back
    rescue Unexistent_element_error => e
      redirect back
    end
  end

  post '/subscription_topic' do
    begin
      Topic_service.subscribe_topic(@current_user, params['sub_topic'])
      redirect back
    rescue Unexistent_element_error => e
      redirect back
    end
  end

  post '/del_subscription_topic' do
    begin
      Topic_service.desubscribe_topic(@current_user, params['sub_topic'])
      redirect back
    rescue Unexistent_element_error => e
      redirect back
    end
  end
end