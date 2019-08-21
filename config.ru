#!/usr/bin/env rackup
# encoding: utf-8

RACK_ENV = (ENV["RACK_ENV"] ||= "development").to_sym unless defined?(RACK_ENV)

# Load our dependencies
require "rubygems" unless defined?(Gem)
require "bundler/setup"
Bundler.require(:default, RACK_ENV)

require File.expand_path("../config/database.rb", __FILE__)
require File.expand_path("../app/entry.rb", __FILE__)
require File.expand_path("../app/time.rb", __FILE__)
require File.expand_path("../app/app.rb", __FILE__)

run Sadnat::App
