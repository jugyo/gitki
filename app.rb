#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'sinatra'
require 'git_store'

class PageNotFound < StandardError; end

BASE_DIR = File.expand_path(File.dirname(__FILE__)) unless defined? BASE_DIR
SETTING = YAML.load(open("#{BASE_DIR}/setting.yml")) unless defined? SETTING
set SETTING
set :store_dir, 'store'
enable :sessions

before do
  @store = GitStore.new(options.git_store)
  @name = params[:name] || 'home'
end

get '/' do
  begin
    wiki @name
  rescue PageNotFound
    redirect "/#{@name}/edit"
  end
end

get '/:name' do
  begin
    wiki @name
  rescue PageNotFound
    redirect "/#{params[:name]}/edit"
  end
end

get '/:name/edit' do
  # TODO: Authentication
  haml :edit
end

post '/:name' do
  # TODO: Authentication
  @store[store_path(@name)] = {:title => params['title'], :body => params['body']}
  @store.commit "Save #{@name}"
  redirect "/#{@name}"
end

get '/css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

def wiki(name)
  @page = @store[store_path(name)]
  raise PageNotFound, name unless @page
  haml :page
end

def store_path(name)
  options.store_dir + '/' + name + '.yml'
end

helpers do
end
