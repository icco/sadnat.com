##
# Setup global project settings for your apps. These settings are inherited by every subapp. You can
# override these settings in the subapps as needed.
#
Padrino.configure_apps do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] || '9asdjj66eeb73b629b5cc'
  set :protection, true
  set :protect_from_csrf, true

  if not ENV['SESSION_SECRET']
    logger.warn "SESSION SECRET IS NOT SECURE."
  end
end

# Mounts the core application for this project
Padrino.mount('Sadnat::App', :app_file => Padrino.root('app/app.rb')).to('/')
