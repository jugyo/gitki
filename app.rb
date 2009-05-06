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
raise 'Invalid markup type.' unless ['textile', 'markdown'].include?(SETTING['markup'])

set SETTING
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
  wiki 'home'
end

get '/pages' do
  @pages = Page.find_all
  haml :pages
end

get '/:name' do
  wiki params[:name]
end

not_found do
  haml '#error-message Not found'
end

helpers do
  def navigation
    textile(Page.find('navigation')[:body])
  end

  def textile(text)
    RedCloth.new(text).to_html
  end

  def wiki(name)
    @name = name
    @page = Page.find(@name) || not_found
    haml :page
  end

  def store_path(name)
    options.wiki_page_dir + '/' + name + '.yml'
  end
end
