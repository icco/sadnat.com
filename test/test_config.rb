PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path('../../config/boot', __FILE__)

class MiniTest::Unit::TestCase
  include RR::Adapters::MiniTest
  include Rack::Test::Methods

  # You can use this method to custom specify a Rack app
  # you want rack-test to invoke:
  #
  #   app Sadnat::App
  #   app Sadnat::App.tap { |a| }
  #   app(Sadnat::App) do
  #     set :foo, :bar
  #   end
  #
  def app(app = nil &blk)
    @app ||= block_given? ? app.instance_eval(&blk) : app
    @app ||= Padrino.application
  end
end
