#!/usr/bin/env ruby
# Sad Nat .com is now dynamic bitches.
# @author Nat Welch - https://github.com/icco

# Settings for the app
configure do
  # Sessions baby!
  set :sessions, true

  # This is how we use heroku's database.
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://data.db')

  # Twiter Keys
  CONS_KEY = 'aPtehhMPyIGjjKnAngkkQ'
  CONS_SEC = ENV['TWITTER_SECRET']
end

# Define helper methods for views
helpers do

  # To help us not dump scary stuff, but still autolink links.
  def h text
    Sanitize.clean(text).gsub( %r{http(s)?://[^\s<]+} ) { |url| "<a href='#{url}'>#{url}</a>" }
  end
end

# Stuff to do before routing requests.
#
# Oauth code based on:
# http://www.lmcalpin.com/post/1178799294/a-little-sinatra-oauth-ditty
before do
  session[:oauth] ||= {}

  if request.host != 'localhost'
    @consumer = OAuth::Consumer.new(CONS_KEY, CONS_SEC, { :site => 'http://twitter.com' })

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
end

# Main index, lists all entries
get '/' do
  erb :index, :locals => { "entries" => Entry.filter(:show => true).reverse_order(:date).all }
end

# Posted to to create new entry
post '/' do
  session["unfinished"] = nil

  # TODO: move to a function
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

# About page.
get '/about' do
  erb :about
end

# Individual entry view
get '/view/:id' do
  erb :view, :locals => { "entry" => Entry.where(:id => params["id"]).first }
end

# Posted to only by nat for editorial content
post '/view/:id' do

  # This can't be secure...
  if session["user"] == "icco"
    entry = Entry.where(:id => params["id"]).first
    entry.response = params["response"]
    entry.show = params["show"]
    entry.save
  end

  redirect "/view/#{entry.id}"
end

# Fancy CSS formatting
get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss :style, :style => :compressed
end

# Force OAuth Login
get '/login' do
  if @request_token.nil?
    redirect '/'
  else
    redirect @request_token.authorize_url
  end
end

# Twitter Callback
get '/authed' do
  @access_token = @request_token.get_access_token

  begin
    response = @access_token.get('/account/verify_credentials.json')

    user = JSON.parse(response.body)

    # Pull out the data we care about
    session['user'] = user['screen_name']

    # TODO: move to a function
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

# Redirect for Natform
get '/game' do
  redirect "https://github.com/icco/platform"
end

# ORM Attachment
class Entry < Sequel::Model(:entries)
end

# Nice time printing
class Time
  def humanize
    if Time.now.strftime("%F") == self.strftime("%F")
      return self.strftime("%l:%M %P")
    elsif Time.now.year == self.year
      return self.strftime("%b %e")
    else
      return self.strftime("%b %e '%y")
    end
  end
end
