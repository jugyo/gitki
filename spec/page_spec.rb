$: << File.dirname(__FILE__) + '/../'
require 'lib/gitki'
require 'tmpdir'
require 'ruby-debug'

include Gitki

describe Page do
  before do
    dir = Dir.tmpdir
    Dir.chdir(dir) do |path|
      system 'rm', '-rf', '.git'
      system 'git', 'init'
    end
    Gitki.setup(dir)
  end

  describe 'when create_default_pages' do
    before(:each) do
      create_default_pages
    end

    it 'should return 2 pages' do
      pages = Page.find_all
      pages.size.should == 2
      
      page = Page.find('home')
      page[:title].should == "Home"
      page[:body].should == read_template('home_template.haml').sub(/\n+\Z/m, '')

      page = Page.find('navigation')
      page[:title].should == "Navigation"
      page[:body].should == read_template('navigation_template.haml').sub(/\n+\Z/m, '')
    end
  end

  describe 'create 2 page' do
    before(:each) do
      Page.create('foo', 'foo', 'foo foo foo')
      Page.create('bar', 'bar', 'bar bar bar')
    end

    it 'should return 2 pages' do
      pages = Page.find_all
      pages.size.should == 2

      page = pages['foo']
      page[:title] = 'foo'
      page[:body] = 'foo foo foo'

      page = pages['bar']
      page[:title] = 'bar'
      page[:body] = 'bar bar bar'
    end
  end
end