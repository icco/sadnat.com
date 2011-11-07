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

# To help us not dump scary stuff.
helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

# http://www.lmcalpin.com/post/1178799294/a-little-sinatra-oauth-ditty
before do
  session["user"] = nil
  session[:oauth] ||= {}

  @consumer = OAuth::Consumer.new(CONS_KEY, CONS_SEC, { :site => 'http://twitter.com/' })

  # generate a request token for this user session if we haven't already
  request_token = session[:oauth][:request_token]
  request_token_secret = session[:oauth][:request_token_secret]
  if request_token.nil? || request_token_secret.nil?
    # new user? create a request token and stick it in their session
    @request_token = @consumer.get_request_token(:oauth_callback => "http://#{request.host}/authed")
    session[:oauth][:request_token] = @request_token.token
    session[:oauth][:request_token_secret] = @request_token.secret
  else
    # we made this user's request token before, so recreate the object
    @request_token = OAuth::RequestToken.new(@consumer, request_token, request_token_secret)
  end

  # this is what we came here for...
  access_token = session[:oauth][:access_token]
  access_token_secret = session[:oauth][:access_token_secret]
  unless access_token.nil? || access_token_secret.nil?
    # the ultimate goal is to get here, where we can create our Twitter @client object
    @access_token = OAuth::AccessToken.new(@consumer, access_token, access_token_secret)
    oauth = Twitter::OAuth.new(CONS_KEY, CONS_SEC)
    oauth.authorize_from_access(@access_token.token, @access_token.secret)
    @client = Twitter::Base.new(oauth)
  end
end

get '/' do
  erb :index, :locals => { "entries" => Entry.reverse_order(:date) }
end

post '/' do
  session["unfinished"] = nil

  # TODO: move to function
  if params["auth"] == "anon" || (params["auth"] == "twitter" && !session["user"].nil?)
    entry = Entry.new
    entry.date = Time.now
    if params["auth"] == "anon"
      entry.username = nil
    else
      entry.username = session["user"]
    end
    entry.reason = params["reason"]
    entry.save
  elsif params["auth"] = "twitter" && session["user"].nil?
    session["unfinished"] = params["reason"]
    redirect '/login'
  end

  redirect '/'
end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss :style, :style => :compressed
end

get '/login' do
  redirect @request_token.authorize_url
end

get '/authed' do
  @access_token = @request_token.get_access_token

  begin
    response = @access_token.get('/account/verify_credentials.json')

    user = JSON.parse(response.body)

    # Pull out the data we care about
    session['user'] = user['screen_name']

    # TODO: move to function
    if !session["unfinished"].nil?
      entry = Entry.new
      entry.date = Time.now
      if params["auth"] == "anon"
        entry.username = nil
      else
        entry.username = session["user"]
      end
      entry.reason = session["unfinished"]
      entry.save
      session["unfinished"] = nil
    end

    redirect '/'
    %(<p>Your OAuth access token: #{@access_token.inspect}</p><p>Your extended profile data:\n#{user.inspect}</p><p>Session:\n#{session}</p>)
  rescue OAuth::Error => e
    p e
    %(<p>Outdated ?code=#{params[:code]}:</p><p>#{$!}</p><p><a href="/login">Retry</a></p>)
  end
end

class Entry < Sequel::Model(:entries)
end

class Time
  def humanize
    if Time.now.strftime("%F") == self.strftime("%F")
      return Time.now.strftime("%l:%M %P")
    elsif Time.now.year == self.year
      return Time.now.strftime("%b %e")
    else
      return Time.now.strftime("%b %e '%y")
    end
  end
end
