ENV['RACK_ENV'] ||= 'production'

pwd = Dir.pwd
git_dir = File.exists?("#{pwd}/.git") ? "#{pwd}/.git" : pwd

SETTING = {
  'title' => 'Gitki',
  'git_store' => git_dir,
  'markup' => 'textile',
}
$: << File.dirname(__FILE__) + '/../'
require 'app'
run Sinatra::Application
