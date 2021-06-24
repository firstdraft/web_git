# Generated by juwelier
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Juwelier::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: web_git 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "web_git".freeze
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Raghu Betina".freeze, "Jelani Woods".freeze]
  s.date = "2020-07-01"
  s.description = "WebGit is a Rails Engine that provides an in-browser visual interface to a simple but effective Git workflow. For educational purposes.".freeze
  s.email = "raghu@firstdraft.com".freeze
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.markdown"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "MIT-LICENSE",
    "README.markdown",
    "Rakefile",
    "VERSION",
    "lib/generators/web_git/install_generator.rb",
    "lib/scripts/heroku_login.exp",
    "lib/views/status.erb",
    "lib/web_git.rb",
    "lib/web_git/diff.rb",
    "lib/web_git/exceptions.rb",
    "lib/web_git/graph.rb",
    "lib/web_git/string.rb",
    "lib/web_git/version.rb",
    "web_git.gemspec"
  ]
  s.homepage = "http://github.com/firstdraft/web_git".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.6".freeze
  s.summary = "An in-browser Git GUI for your Rails project".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sinatra>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<git>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<diffy>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<actionview>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<tzinfo-data>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<ansispan>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 3.12"])
      s.add_development_dependency(%q<juwelier>.freeze, ["~> 2.1.0"])
    else
      s.add_dependency(%q<ansispan>.freeze, [">= 0"])
      s.add_dependency(%q<sinatra>.freeze, [">= 0"])
      s.add_dependency(%q<git>.freeze, [">= 0"])
      s.add_dependency(%q<diffy>.freeze, [">= 0"])
      s.add_dependency(%q<actionview>.freeze, [">= 0"])
      s.add_dependency(%q<tzinfo-data>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 3.12"])
      s.add_dependency(%q<juwelier>.freeze, ["~> 2.1.0"])
    end
  else
    s.add_dependency(%q<ansispan>.freeze, [">= 0"])
    s.add_dependency(%q<sinatra>.freeze, [">= 0"])
    s.add_dependency(%q<git>.freeze, [">= 0"])
    s.add_dependency(%q<diffy>.freeze, [">= 0"])
    s.add_dependency(%q<actionview>.freeze, [">= 0"])
    s.add_dependency(%q<tzinfo-data>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 3.12"])
    s.add_dependency(%q<juwelier>.freeze, ["~> 2.1.0"])
  end
end

