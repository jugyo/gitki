# -*- coding: utf-8 -*-
$: << File.dirname(__FILE__) + '/../vendor/git_store/lib'

require 'rubygems'
require 'git_store'
require 'redcloth' rescue nil
require 'rdiscount' rescue nil

module Gitki
  class << self
    def setup(git_store_path)
      @@store = GitStore.new(File.expand_path(git_store_path), 'master', true) # use bare repository
      Page.setup('wiki')
      Attachment.setup('files')
      if @@store.objects.empty?
        create_defaults
      end
    end

    def create_defaults
      @@store[Page.dir + '/home'] = read_file('home_template.haml')
      @@store[Page.dir + '/navigation'] = read_file('navigation_template.haml')
      @@store[Attachment.dir + '/gitki.png'] = read_file('gitki.png')
      @@store.commit 'Created defaults'
    end

    def read_file(name)
      open(File.dirname(__FILE__) + '/' + name).read
    end
  end

  def markup_types
    ['html', 'textile', 'markdown']
  end

  def store
    @@store
  end

  def textile(text)
    RedCloth.new(text).to_html
  end

  def markdown(text)
    RDiscount.new(text).to_html
  end

  def html(text)
    text
  end

  class Page
    class << self
      attr_reader :dir
      def setup(dir)
        @dir = dir
      end

      def find_all
        pages = {}
        store[dir].to_hash.each do |name, text|
          pages[name] = self.new(text)
        end
        pages
      end

      def find(name)
        self.new(store[store_path(name)])
      end

      def store_path(name)
        File.join(dir, name)
      end
    end

    attr_reader :title, :body

    def initialize(row)
      @row = row
      @title, @body = split_title_and_body(row)
    end

    def split_title_and_body(row)
      return nil if row.nil? || row.empty?
      lines = row.split("\n")
      title = lines.shift
      lines.shift
      body = lines.join("\n")
      [title, body]
    end
  end

  class Attachment
    class << self
      attr_reader :dir
      def setup(dir)
        @dir = dir
      end

      def find(name)
        store[store_path(name)]
      end

      def store_path(name)
        File.join(dir, name)
      end
    end
  end
end
