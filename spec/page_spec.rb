$: << File.dirname(__FILE__) + '/../'
require 'lib/gitki'
require 'tmpdir'
require 'ruby-debug'
require 'fileutils'

include Gitki

describe Gitki do
  REPO = File.join Dir.tmpdir, 'git_store_test'

  before do
    FileUtils.rm_rf REPO
    Dir.mkdir REPO
    Dir.chdir(REPO) do |path|
      system 'git', 'init', '--bare'
    end
    Gitki.setup(REPO)
  end

  describe Page do
    it 'should return 2 pages' do
      pages = Page.find_all
      pages.size.should == 2
    
      page = Page.find('home')
      page[:title].should == "Home"
      page[:body].should == Gitki.read_template('home_template.haml').sub(/\n+\Z/m, '')

      page = Page.find('navigation')
      page[:title].should == "Navigation"
      page[:body].should == Gitki.read_template('navigation_template.haml').sub(/\n+\Z/m, '')
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
      Gitki.store['files/test.txt'] = 'test'
    end

    it 'should get file content' do
      Attachment.find('test.txt').should == 'test'
    end
  end
end
