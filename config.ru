# Gemfile
require "rubygems"
require "bundler/setup"
require "sinatra"
require "./app"
require 'erb'
require 'pony'

set :run, false
set :raise_errors, true

run BuilderRoutes
