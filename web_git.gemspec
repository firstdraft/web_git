# Generated by juwelier
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Juwelier::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: web_git 0.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "web_git".freeze
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Raghu Betina".freeze, "Jelani Woods".freeze]
  s.date = "2019-05-06"
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
    "ansi2html.sh",
    "app/assets/javascripts/web_git/application.js",
    "app/assets/javascripts/web_git/bootstrap.min.js",
    "app/assets/javascripts/web_git/popper.min.js",
    "app/assets/stylesheets/web_git/application.scss",
    "app/assets/stylesheets/web_git/bootstrap.min.css",
    "app/assets/stylesheets/web_git/font-awesome.min.css",
    "app/assets/stylesheets/web_git/octicons.css",
    "app/controllers/web_git/application_controller.rb",
    "app/controllers/web_git/branches_controller.rb",
    "app/controllers/web_git/commands_controller.rb",
    "app/controllers/web_git/commits_controller.rb",
    "app/views/layouts/web_git/application.html.erb",
    "app/views/web_git/commands/status.html.erb",
    "config/routes.rb",
    "lib/web_git.rb",
    "lib/web_git/diff.rb",
    "lib/web_git/engine.rb",
    "lib/web_git/version.rb",
    "web_git.gemspec"
  ]
  s.homepage = "http://github.com/firstdraft/web_git".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.1".freeze
  s.summary = "An in-browser Git GUI for your Rails project".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<diffy>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<tzinfo-data>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<tether-rails>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<octicons_helper>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<turbolinks>.freeze, ["~> 5"])
      s.add_runtime_dependency(%q<jquery-rails>.freeze, [">= 0"])
      s.add_runtime_dependency(%q<git_clone_url>.freeze, [">= 0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<juwelier>.freeze, ["~> 2.1.0"])
      s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry>.freeze, ["~> 0"])
      s.add_development_dependency(%q<pry-byebug>.freeze, ["~> 3"])
      s.add_development_dependency(%q<pry-doc>.freeze, ["~> 0"])
      s.add_development_dependency(%q<pry-remote>.freeze, ["~> 0"])
      s.add_development_dependency(%q<pry-rescue>.freeze, ["~> 1"])
      s.add_development_dependency(%q<pry-stack_explorer>.freeze, ["~> 0"])
    else
      s.add_dependency(%q<diffy>.freeze, [">= 0"])
      s.add_dependency(%q<tzinfo-data>.freeze, [">= 0"])
      s.add_dependency(%q<tether-rails>.freeze, [">= 0"])
      s.add_dependency(%q<octicons_helper>.freeze, [">= 0"])
      s.add_dependency(%q<turbolinks>.freeze, ["~> 5"])
      s.add_dependency(%q<jquery-rails>.freeze, [">= 0"])
      s.add_dependency(%q<git_clone_url>.freeze, [">= 0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 3.12"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
      s.add_dependency(%q<juwelier>.freeze, ["~> 2.1.0"])
      s.add_dependency(%q<simplecov>.freeze, [">= 0"])
      s.add_dependency(%q<pry>.freeze, ["~> 0"])
      s.add_dependency(%q<pry-byebug>.freeze, ["~> 3"])
      s.add_dependency(%q<pry-doc>.freeze, ["~> 0"])
      s.add_dependency(%q<pry-remote>.freeze, ["~> 0"])
      s.add_dependency(%q<pry-rescue>.freeze, ["~> 1"])
      s.add_dependency(%q<pry-stack_explorer>.freeze, ["~> 0"])
    end
  else
    s.add_dependency(%q<diffy>.freeze, [">= 0"])
    s.add_dependency(%q<tzinfo-data>.freeze, [">= 0"])
    s.add_dependency(%q<tether-rails>.freeze, [">= 0"])
    s.add_dependency(%q<octicons_helper>.freeze, [">= 0"])
    s.add_dependency(%q<turbolinks>.freeze, ["~> 5"])
    s.add_dependency(%q<jquery-rails>.freeze, [">= 0"])
    s.add_dependency(%q<git_clone_url>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5.0"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 3.12"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.0"])
    s.add_dependency(%q<juwelier>.freeze, ["~> 2.1.0"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<pry>.freeze, ["~> 0"])
    s.add_dependency(%q<pry-byebug>.freeze, ["~> 3"])
    s.add_dependency(%q<pry-doc>.freeze, ["~> 0"])
    s.add_dependency(%q<pry-remote>.freeze, ["~> 0"])
    s.add_dependency(%q<pry-rescue>.freeze, ["~> 1"])
    s.add_dependency(%q<pry-stack_explorer>.freeze, ["~> 0"])
  end
end

