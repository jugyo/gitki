# -*- coding: utf-8 -*-

ENV['RACK_ENV'] ||= 'production'

require 'app'
run Sinatra::Application
