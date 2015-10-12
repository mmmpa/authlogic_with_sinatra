require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/cookies'
require 'sinatra/reloader' if development?
require 'active_support'
require 'slim'
require 'pp'

Dir["#{__dir__}/initializers/**/*.rb"].each(&method(:require))
Dir["#{__dir__}/app/**/*.rb"].each(&method(:require))

set :views, "#{__dir__}/app/views/"
enable :sessions

before '/room' do
  redirect '/in' unless !!UserSession.find
end

before '/in' do
  redirect '/room' if !!UserSession.find
end

after do
  ActiveRecord::Base.connection.close
end

get '/' do
  slim :index
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
    #persist_session(UserSession.create!(in_params))
    redirect '/room'
  rescue Authlogic::Session::Existence::SessionInvalidError => e
    @in = e.record
    slim :user_in
  end
end

post '/out' do
  UserSession.find.try(:destroy)
  #clear_session(UserSession.find)
  redirect '/'
end

get '/room' do
  @user = current_user
  slim :room
end

private

def current_user
  UserSession.find.try(:user)
end

#sessionを使用しない場合
#initializers/authlogic_sinatra_adapterのコメントアウトを外してこれを使う
def persist_session(authlogic_session)
  cookies[authlogic_session.for_cookie[:key]] = authlogic_session.for_cookie[:value]
end

#sessionを使用しない場合
#initializers/authlogic_sinatra_adapterのコメントアウトを外してこれを使う
def clear_session(authlogic_session)
  return unless authlogic_session
  cookies[authlogic_session.for_cookie[:key]] = nil
end

def symbolize_params
  @normalized ||= params.deep_symbolize_keys!
end

def user_params
  symbolize_params.slice(:login, :email, :password)
end

def in_params
  symbolize_params.slice(:login, :password)
end

