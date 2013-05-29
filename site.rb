#!/usr/bin/env ruby
# Sad Nat .com is now dynamic bitches.
# @author Nat Welch - https://github.com/icco

# Settings for the app
configure do
  # Sessions baby!
  set :sessions, true
  set :session_secret, ENV['SESSION_SECRET'] || 'fakity fake fake.'

  set :protection, true
  set :protect_from_csrf, true

  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://db/data.db')

  # Twiter Keys
  CONS_KEY = 'aPtehhMPyIGjjKnAngkkQ'
  CONS_SEC = ENV['TWITTER_SECRET']
end

# Define helper methods for views
helpers do

  # To help us not dump scary stuff, but still autolink links.
  def h text
    # Clean out html
    out = Sanitize.clean text

    # Link links
    out = out.gsub( %r{http(s)?://[^\s<]+} ) { |url| "<a href='#{url}'>#{url}</a>" }

    # Link Twitter Handles
    out = out.gsub(/@(\w+)/) {|a| "<a href=\"http://twitter.com/#{a[1..-1]}\"/>#{a}</a>" }

    return out
  end
end

# Stuff to do before routing requests.
use OmniAuth::Builder do
  provider :twitter,  CONS_KEY, CONS_SEC
end

# Main index, lists all entries
get '/' do
  erb :index, :locals => { "entries" => Entry.filter(:show => true).reverse_order(:date).all }
end

# Posted to to create new entry
post '/' do
  session["unfinished"] = nil

  if params['authenticity_token'] != session['csrf']
    logger.debug "#{params['authenticity_token']} != #{session['csrf']}"
  end

  # TODO: move to a function
  if params["reason"]
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
  redirect '/auth/twitter'
end

# Twitter Callback
get '/auth/twitter/callback' do
  auth = request.env['omniauth.auth']
  session['user'] = auth["info"].nickname

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
end

# url hit when auth fails.
# /auth/failure?message=invalid_credentials&origin=http%3A%2F%2Fsadnat.com%2F&strategy=twitter
get '/auth/failure' do
  session['user'] = nil
  puts "Failed auth: #{params.inspect}"

  redirect '/'
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
