module Sadnat
  class App < Padrino::Application
    register SassInitializer
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers

    enable :sessions

    # Twiter Keys
    CONS_KEY = 'aPtehhMPyIGjjKnAngkkQ'
    CONS_SEC = ENV['TWITTER_SECRET']

    # Stuff to do before routing requests.
    use OmniAuth::Builder do
      provider :twitter,  CONS_KEY, CONS_SEC
    end
  end
end
