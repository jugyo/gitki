#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'sinatra'
require 'mime/types'
require 'yaml'
require 'lib/gitki'
require 'digest/md5'
include Gitki

configure do
  BASE_DIR = File.expand_path(File.dirname(__FILE__)) unless defined? BASE_DIR
  SETTING = YAML.load(open("#{BASE_DIR}/setting.yml")) unless defined? SETTING

  SETTING['markup'] ||= 'textile'
  raise 'Invalid markup type.' unless markup_types.include?(SETTING['markup'])

  set SETTING
  set :haml, {:format => :html5}
  enable :sessions

  Gitki.setup(SETTING['git_store'])

  repo_path = File.expand_path SETTING['git_store']
  puts <<-EOS

#{'#' * 60}

  Wiki repository is '#{repo_path}'.
  You can clone it as follows:

   % git clone <user>@<host>:#{repo_path}

#{'#' * 60}

  EOS
end

before do
  store.refresh!
  content_type "text/html", :charset => "utf-8"
end

get '/css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :styles
end

get '/files/:name' do
  content_type MIME::Types.type_for(params[:name]).first.content_type
  data = Attachment.find(params[:name])
  etag Digest::MD5.hexdigest(data)
  data
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

get '/raw/:name' do
  content_type 'text/plain', :charset => 'utf-8'
  Page.find(params[:name]).raw
end

not_found do
  haml '#error-message Not found'
end

helpers do
  def navigation
    markup(Page.find('navigation').body)
  end

  def markup(text)
    self.__send__(options.markup, text)
  end

  def wiki(name)
    @name = name
    @page = Page.find(@name) || not_found
    haml :page
  end
end
