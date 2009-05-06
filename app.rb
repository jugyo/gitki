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
  @pages = Page.find_all
  haml :pages
end

get '/:name' do
  @name = params[:name]
  begin
    wiki @name
  rescue PageNotFound
    redirect "/#{params[:name]}/edit"
  end
end

helpers do

  def navigation
    textile(Page.find('navigation')[:body])
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
    @page = Page.find(name)
    raise PageNotFound, name unless @page
    haml :page
  end

  def store_path(name)
    options.wiki_page_dir + '/' + name + '.yml'
  end
end
