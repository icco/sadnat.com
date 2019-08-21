require "google/cloud/logging"

module Sadnat
  class App < Sinatra::Base
    logger = Logger.new(STDOUT)
    env['rack.logger'] = logger

    use ActiveRecord::ConnectionAdapters::ConnectionManagement

    enable :sessions
    enable :logging
    set :session_secret, ENV['SESSION_SECRET'] || '9asdjj66eeb73b629b5cc'
    set :protection, true
    set :protect_from_csrf, true

    if not ENV['SESSION_SECRET']
      logger.warn "SESSION SECRET IS NOT SECURE."
    end

    # Twiter Keys
    CONS_KEY = 'aPtehhMPyIGjjKnAngkkQ'
    CONS_SEC = ENV['TWITTER_SECRET']

    # Stuff to do before routing requests.
    use OmniAuth::Builder do
      provider :twitter,  CONS_KEY, CONS_SEC
    end

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

    # Main index, lists all entries
    get '/' do
      binding.remote_pry
      @entries = Entry.where(:show => true).order("date desc").all
      erb :index
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
      @total_count = Entry.where(:show => true).order("date desc").all.count
      erb :about
    end

    get '/fail' do
      erb :fail
    end

    # Individual entry view
    get '/view/:id' do
      @entry = Entry.where(:id => params[:id]).first

      if not @entry
        404
      else
        erb :view
      end
    end

    # Posted to only by nat for editorial content
    post '/view/:id' do
      p params

      # This can't be secure...
      if session["user"] == "icco"
        entry = Entry.where(:id => params[:id]).first
        entry.response = params["response"]
        entry.show = params["show"]
        entry.save
      end

      redirect "/view/#{entry.id}"
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

  end
end
