module Gitki
  def self.setup(git_store_path)
    @@store = GitStore.new(git_store_path)
  end

  def store
    @@store
  end

  def create_default_pages
    create_home unless page('home')
    create_navigation unless page('navigation')
  end

  def create_home
    template = open(File.dirname(__FILE__) + '/home_template.haml').read
    store[store_path('home')] = {:title => 'Home', :body => template}
    store.commit 'Create as defaut'
  end

  def create_navigation
    template = open(File.dirname(__FILE__) + '/navigation_template.haml').read
    store[store_path('navigation')] = {:title => 'Navigation', :body => template}
    store.commit 'Create as defaut'
  end

  class Page
    
  end
end
