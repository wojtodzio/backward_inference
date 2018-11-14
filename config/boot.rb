# Set up gems listed in the Gemfile
require 'rubygems'
require 'bundler/setup'

CURRENT_ENV = ENV.fetch('APP_ENV', DEFAULT_ENV)
Bundler.require(:default, CURRENT_ENV)

require_relative 'app'
