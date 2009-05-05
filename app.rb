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
  create_home unless page('home')
  create_navigation unless page('navigation')
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

helpers do
  def wiki_pages
    pages = {}
    store[options.wiki_page_dir].to_hash.each do |k, v|
      pages[k.sub(/\.yml$/, '')] = v
    end
    pages
  end

  def navigation
    begin
      template = page('navigation')[:body]
      engine = Haml::Engine.new(template)
      engine.render(self)
    rescue => e
      "<pre style=\"color: red;\"><code>#{e.class.to_s}: #{e.message}</code></pre>"
    end
  end

  def partial(template, options = {})
    options = options.merge({:layout => false})
    template = "#{template.to_s}".to_sym
    haml(template, options)
  end
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
  store[store_path(name)]
end

def store_path(name)
  options.wiki_page_dir + '/' + name + '.yml'
end

def create_home
  template = open(File.dirname(__FILE__) + '/home_template.haml').read
  store[store_path('home')] = {:title => 'Home', :body => template}
  store.commit
end

def create_navigation
  template = open(File.dirname(__FILE__) + '/navigation_template.haml').read
  store[store_path('navigation')] = {:title => 'Navigation', :body => template}
  store.commit
end
