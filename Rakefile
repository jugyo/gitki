require 'spec/rake/spectask'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'

desc "default task"
task :default => [:spec]

name = 'gitki'
version = '0.1.0'

spec = Gem::Specification.new do |s|
  s.name = name
  s.version = version
  s.summary = "Gitki is a wiki using git to store data."
  s.description = "Gitki is a wiki using git to store data."
  s.files = %w(Rakefile README.rdoc ChangeLog app.rb config.ru console setting.yml) + 
            Dir.glob("{lib,spec,bin,public,vendor,views}/**/*")
  s.executables = ["gitki"]
  s.add_dependency("sinatra", ">= 0.9.4")
  s.authors = %w(jugyo)
  s.email = 'jugyo.org@gmail.com'
  s.homepage = 'http://github.com/jugyo/gitki'
  s.rubyforge_project = 'gitki'
  s.has_rdoc = false
end

Rake::GemPackageTask.new(spec) do |p|
  p.need_tar = true
end

task :gemspec do
  filename = "#{name}.gemspec"
  open(filename, 'w') do |f|
    f.write spec.to_ruby
  end
  puts <<-EOS
  Successfully generated gemspec
  Name: #{name}
  Version: #{version}
  File: #{filename}
  EOS
end

task :install => [ :package ] do
  sh %{sudo gem install pkg/#{name}-#{version}.gem}
end

task :uninstall => [ :clean ] do
  sh %{sudo gem uninstall #{name}}
end

desc 'run all specs'
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['-c']
end

CLEAN.include ['pkg']
