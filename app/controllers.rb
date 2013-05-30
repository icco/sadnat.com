Sadnat::App.controllers  do
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
