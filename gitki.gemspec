# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gitki}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["jugyo"]
  s.date = %q{2009-08-11}
  s.default_executable = %q{gitki}
  s.description = %q{Gitki is a wiki using git to store data.}
  s.email = %q{jugyo.org@gmail.com}
  s.executables = ["gitki"]
  s.files = ["Rakefile", "README.rdoc", "ChangeLog", "app.rb", "config.ru", "console", "setting.yml", "lib/gitki.png", "lib/gitki.rb", "lib/home_template.haml", "lib/navigation_template.haml", "spec/gitki_spec.rb", "bin/gitki", "bin/gitki.ru", "public/background.png", "public/favicon.ico", "vendor/git_store", "vendor/git_store/git_store.gemspec", "vendor/git_store/lib", "vendor/git_store/lib/git_store", "vendor/git_store/lib/git_store/blob.rb", "vendor/git_store/lib/git_store/commit.rb", "vendor/git_store/lib/git_store/diff.rb", "vendor/git_store/lib/git_store/handlers.rb", "vendor/git_store/lib/git_store/pack.rb", "vendor/git_store/lib/git_store/tag.rb", "vendor/git_store/lib/git_store/tree.rb", "vendor/git_store/lib/git_store/user.rb", "vendor/git_store/lib/git_store.rb", "vendor/git_store/LICENSE", "vendor/git_store/Rakefile", "vendor/git_store/README.md", "vendor/git_store/test", "vendor/git_store/test/bare_store_spec.rb", "vendor/git_store/test/benchmark.rb", "vendor/git_store/test/commit_spec.rb", "vendor/git_store/test/git_store_spec.rb", "vendor/git_store/test/helper.rb", "vendor/git_store/test/tree_spec.rb", "vendor/git_store/TODO", "views/layout.haml", "views/page.haml", "views/pages.haml", "views/styles.sass"]
  s.homepage = %q{http://github.com/jugyo/gitki}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{gitki}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Gitki is a wiki using git to store data.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sinatra>, [">= 0.9.4"])
    else
      s.add_dependency(%q<sinatra>, [">= 0.9.4"])
    end
  else
    s.add_dependency(%q<sinatra>, [">= 0.9.4"])
  end
end
