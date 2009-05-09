$: << File.dirname(__FILE__) + '/../'
require 'lib/gitki'
require 'tmpdir'
require 'ruby-debug'
require 'fileutils'

include Gitki

describe Gitki do
  REPO = File.join Dir.tmpdir, 'git_store_test'

  before(:each) do
    FileUtils.rm_rf REPO
    Dir.mkdir REPO
    Dir.chdir(REPO) do |path|
      system 'git', 'init', '--bare'
    end
  end

  describe 'repository is empty' do
    it 'should create defaults' do
      Gitki.should_receive(:create_defaults)
      Gitki.setup(REPO)
    end

    it 'should return 2 pages' do
      Gitki.setup(REPO)

      pages = Page.find_all
      pages.size.should == 2
    
      page = Page.find('home')
      page[:title].should == "Home"
      page[:body].should == Gitki.read_template('home_template.haml').sub(/\n+\Z/m, '')

      page = Page.find('navigation')
      page[:title].should == "Navigation"
      page[:body].should == Gitki.read_template('navigation_template.haml').sub(/\n+\Z/m, '')
    end
  end
  

  describe 'repository is not empty' do
    before(:each) do
      store = GitStore.new(REPO, 'master', true)
      store['test.txt'] = 'test'
      store.commit 'Added test.txt'
    end

    it 'should not create defaults' do
      Gitki.should_not_receive(:create_defaults)
      Gitki.setup(REPO)
    end
  end

  describe Page do
    before(:each) do
      Gitki.setup(REPO)
    end

    describe 'create 2 page' do
      before(:each) do
        Page.create('foo', 'foo', 'foo foo foo')
        Page.create('bar', 'bar', 'bar bar bar')
      end

      it 'should return 2 pages' do
        pages = Page.find_all
        pages.size.should == 4

        page = pages['foo']
        page[:title] = 'foo'
        page[:body] = 'foo foo foo'

        page = pages['bar']
        page[:title] = 'bar'
        page[:body] = 'bar bar bar'
      end
    end
  end

  describe Attachment do
    before(:each) do
      Gitki.setup(REPO)
      Gitki.store['files/test.txt'] = 'test'
    end

    it 'should get file content' do
      Attachment.find('test.txt').should == 'test'
    end
  end
end
