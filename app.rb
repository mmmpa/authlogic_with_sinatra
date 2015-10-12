require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/cookies'
require 'sinatra/reloader' if development?
require 'active_support'
require 'slim'
require 'pp'

Dir["#{__dir__}/app/**/*.rb"].each(&method(:require))

set :views, "#{__dir__}/app/views/"
enable :session

before do
  pp UserSession.find
end

get '/' do
  'Hello world!'
end

get '/users/new' do
  @user = User.new
  slim :user_new
end

post '/users/new' do
  begin
    User.create!(user_params)
    redirect '/in'
  rescue ActiveRecord::RecordInvalid => e
    @user = e.record
    slim :user_new
  end
end

get '/in' do
  @in = UserSession.new
  slim :user_in
end

post '/in' do
  begin
    UserSession.create!(in_params)
    @in = UserSession.new
    slim :user_in
  rescue Authlogic::Session::Existence::SessionInvalidError => e
    @in = e.record
    slim :user_in
  end
end

post '/out' do
  #destroy
end

def normal_params
  @normalized ||= pp params.deep_symbolize_keys!
end

def user_params
  normal_params.slice(:login, :email, :password)
end

def in_params
  normal_params.slice(:login, :password)
end

module Authlogic
  module ControllerAdapters
    module SinatraAdapter
      class Adapter < AbstractAdapter
        def session
          request.session
        end
      end
    end
  end
end
