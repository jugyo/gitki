require 'rubygems'
require 'git_store'
require 'redcloth' rescue nil
require 'rdiscount' rescue nil

module Gitki
  class << self
    def setup(git_store_path, wiki_dir = 'wiki')
      @@store = GitStore.new(File.expand_path(git_store_path), 'master', true) # use bare repository
      @@wiki_dir = wiki_dir
      create_default_pages
    end

    def create_default_pages
      create_home unless Page.find('home')
      create_navigation unless Page.find('navigation')
    end

    def create_home
      Page.create('home', 'Home', read_template('home_template.haml'))
    end

    def create_navigation
      Page.create('navigation', 'Navigation', read_template('navigation_template.haml'))
    end

    def read_template(name)
      open(File.dirname(__FILE__) + '/' + name).read
    end
  end

  def markup_types
    ['html', 'textile', 'markdown']
  end

  def store
    @@store
  end

  def wiki_dir
    @@wiki_dir
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
      def find_all
        pages = {}
        store[wiki_dir].to_hash.each do |name, text|
          pages[name] = split_title_and_body(text)
        end
        pages
      end

      def find(name)
        split_title_and_body(store[store_path(name)])
      end

      def create(name, title, body)
        store[store_path(name)] = "#{title}\n\n#{body}"
        store.commit
      end

      def store_path(name)
        File.join(wiki_dir, name)
      end

      def split_title_and_body(text)
        return nil if text.nil? || text.empty?
        lines = text.split("\n")
        title = lines.shift
        lines.shift
        body = lines.join("\n")
        {:title => title, :body => body}
      end
    end
  end
end
