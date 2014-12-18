# Gemfile
require "rubygems"
require "bundler/setup"
require "sinatra"
require "./app"
require 'erb'

set :run, false
set :raise_errors, true

run BuilderRoutes
