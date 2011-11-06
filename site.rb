#!/usr/bin/env ruby
# Sad Nat .com is now dynamic bitches.
# @author Nat Welch - https://github.com/icco

configure do
  # Sessions baby!
  set :sessions, true

  # This is how we use heroku's database.
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://data.db')
end

get '/' do
  erb :index, :locals => {}
end

post '/' do
  redirect '/'
end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  less :style
end

class Entry < Sequel::Model(:entries)
end
