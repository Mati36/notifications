require 'json'
require './services/topic_service.rb'
require 'sinatra/base'
require './exceptions/validation_model_error.rb'


class Topic_controller < Sinatra::Base
  configure :development, :production do
    set :views, settings.root + '/../views'
  end

  before do
    @current_user = User.find(id: session[:user_id])
  end

  post '/add_topic' do
    begin
      Topic_service.add_topic(params['topic'])
      redirect back
    rescue Validation_model_error => e
      redirect back
    end
  end

  get '/topic_list' do
      @topics = Topic.all
      erb :topic_list 
  end

  post '/delete_topic' do
    topic_id = params['del_topic']
    Topic_service.delete_topic(topic_id)
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

end