#!/usr/bin/env ruby
# Sad Nat .com is now dynamic bitches.
# @author Nat Welch - https://github.com/icco

configure do
  # Sessions baby!
  set :sessions, true

  # This is how we use heroku's database.
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://data.db')

  # Twiter Keys
  CONS_KEY = 'aPtehhMPyIGjjKnAngkkQ'
  CONS_SEC = ENV['TWITTER_SECRET']
end

# Oauth Stuff for Twitter
def client
  OAuth::Consumer.new(CONS_KEY, CONS_SEC, {
    :site => 'http://twitter.com/',
    :request_token_path => '/oauth/request_token',
    :access_token_path => '/oauth/access_token',
    :authorize_path => '/oauth/authorize'
  })
end

get '/' do
  erb :index, :locals => {}
end

post '/' do
  redirect '/'
end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end

get '/login' do
  request_token = client.get_request_token(:oauth_callback => "http://#{request.host}/authed")
  url = request_token.authorize_url

  redirect url
end

get '/authed' do
  begin
    p params
    session["code"] = params[:code]
    access_token = client.auth_code.get_token(params[:code])
    user = JSON.parse(access_token.get('/user').body)

    # Pull out the data we care about
    session['user'] = user["login"]
    session['token'] = access_token.token

    %(<p>Your OAuth access token: #{access_token.token}</p><p>Your extended profile data:\n#{user.inspect}</p>)
  rescue OAuth2::Error => e
    %(<p>Outdated ?code=#{params[:code]}:</p><p>#{$!}</p><p><a href="/login">Retry</a></p>)
  end
end

class Entry < Sequel::Model(:entries)
end
