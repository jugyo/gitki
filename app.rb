#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'sinatra'
require 'yaml'
require 'redcloth'
require 'git_store'
require 'page'
include Gitki

class PageNotFound < StandardError; end

BASE_DIR = File.expand_path(File.dirname(__FILE__)) unless defined? BASE_DIR
SETTING = YAML.load(open("#{BASE_DIR}/setting.yml")) unless defined? SETTING
set SETTING
set :wiki_page_dir, 'wiki'
set :reserve_pages, ['pages', 'css']
set :haml, {:format => :html5 }
enable :sessions

Gitki.setup(SETTING['git_store'])

before do
  content_type "text/html", :charset => "utf-8"
  create_default_pages
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

get '/pages' do
  haml :pages
end

get '/search' do
  # TODO
  raise PageNotFound
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
  if options.reserve_pages.include?(params[:name])
    redirect "/#{params[:name]}"
  end
  @name = params[:name]
  @page = page(@name) || {:title => '', :body => ''}
  haml :edit
end

post '/:name' do
  # TODO: Authentication
  if options.reserve_pages.include?(params[:name])
    redirect "/#{params[:name]}"
  end
  @name = params[:name]
  @store[store_path(@name)] = {:title => params['title'], :body => params['body']}
  @store.commit "Save #{@name}"
  redirect "/#{@name}"
end

helpers do
  def page(name)
    store[store_path(name)]
  end

  def wiki_pages
    pages = {}
    store[options.wiki_page_dir].to_hash.each do |k, v|
      pages[k.sub(/\.yml$/, '')] = v
    end
    pages
  end

  def navigation
    textile(page('navigation')[:body])
  end

  def partial(template, options = {})
    options = options.merge({:layout => false})
    template = "#{template.to_s}".to_sym
    haml(template, options)
  end

  def textile(text)
    RedCloth.new(text).to_html
  end

  def wiki(name)
    @page = page(name)
    raise PageNotFound, name unless @page
    haml :page
  end

  def store_path(name)
    options.wiki_page_dir + '/' + name + '.yml'
  end
end
