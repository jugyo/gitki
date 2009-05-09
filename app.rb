#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$: << File.dirname(__FILE__) + '/vendor/git_store/lib'

require 'rubygems'
require 'sinatra'
require 'yaml'
require 'git_store'
require 'lib/gitki'
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

  puts <<-EOS

#{'#' * 60}

  Wiki repository is '#{File.expand_path SETTING['git_store']}'.
  You can clone it as follows:
  % git clone #{File.expand_path SETTING['git_store']}

#{'#' * 60}

  EOS
end

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
    markup(Page.find('navigation')[:body])
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
