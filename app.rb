#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'sinatra'
require 'yaml'
require 'git_store'

class PageNotFound < StandardError; end

BASE_DIR = File.expand_path(File.dirname(__FILE__)) unless defined? BASE_DIR
SETTING = YAML.load(open("#{BASE_DIR}/setting.yml")) unless defined? SETTING
set SETTING
set :wiki_page_dir, 'wiki'
enable :sessions

before do
  @store = GitStore.new(options.git_store)
end

get '/css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

get '/' do
  @name = 'home'
  begin
    wiki @name
  rescue PageNotFound
    redirect "/#{@name}/edit"
  end
end

get '/:name' do
  @name = params[:name]
  begin
    wiki @name
  rescue PageNotFound
    redirect "/#{params[:name]}/edit"
  end
end

get '/:name/edit' do
  # TODO: Authentication
  @name = params[:name]
  @page = page(@name) || {:title => '', :body => ''}
  haml :edit
end

post '/:name' do
  # TODO: Authentication
  @name = params[:name]
  @store[store_path(@name)] = {:title => params['title'], :body => params['body']}
  @store.commit "Save #{@name}"
  redirect "/#{@name}"
end

def store
  @store
end

def wiki(name)
  @page = page(name)
  raise PageNotFound, name unless @page
  haml :page
end

def page(name)
  @store[store_path(name)]
end

def store_path(name)
  options.wiki_page_dir + '/' + name + '.yml'
end

helpers do
  def partial(template, options = {})
    options = options.merge({:layout => false})
    template = "#{template.to_s}".to_sym
    haml(template, options)
  end
end
