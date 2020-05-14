require "bundler"
require "sinatra"
require 'sequel'

Bundler.require

#Create connection anda leave it as a global objet in our project
DB = Sequel.connect(
    adapter: 'postgres',
    database: 'notificator-development',
    host: 'db',
    user: 'unicorn',
    password: 'magic')

require "./app.rb"
run App
