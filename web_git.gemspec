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
  s.authors = ["Raghu Betina".freeze]
  s.date = "2017-06-20"
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
    "README.markdown",
    "Rakefile",
    "VERSION",
    "app/assets/config/web_git_manifest.js",
    "app/assets/images/web_git/.keep",
    "app/assets/javascripts/web_git/application.js",
    "app/assets/stylesheets/web_git/application.scss",
    "app/assets/stylesheets/web_git/octicons.css",
    "app/controllers/web_git/application_controller.rb",
    "app/controllers/web_git/branches_controller.rb",
    "app/controllers/web_git/commands_controller.rb",
    "app/controllers/web_git/commits_controller.rb",
    "app/helpers/web_git/application_helper.rb",
    "app/jobs/web_git/application_job.rb",
    "app/mailers/web_git/application_mailer.rb",
    "app/models/web_git/application_record.rb",
    "app/views/layouts/web_git/application.html.erb",
    "app/views/web_git/commands/status.html.erb",
    "config/routes.rb",
    "lib/tasks/web_git_tasks.rake",
    "lib/web_git.rb",
    "lib/web_git/engine.rb",
    "web_git.gemspec"
  ]
  s.homepage = "http://github.com/firstdraft/web_git".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.6.11".freeze
  s.summary = "An in-browser Git GUI for your Rails project".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<tzinfo-data>, [">= 0"])
      s.add_runtime_dependency(%q<bootstrap>, ["~> 4.0.0.alpha6"])
      s.add_runtime_dependency(%q<tether-rails>, [">= 0"])
      s.add_runtime_dependency(%q<octicons_helper>, [">= 0"])
      s.add_runtime_dependency(%q<turbolinks>, ["~> 5"])
      s.add_runtime_dependency(%q<jquery-rails>, ["= 4.3.1"])
      s.add_development_dependency(%q<rspec>, ["~> 3.5.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<juwelier>, ["~> 2.1.0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<pry>, ["~> 0"])
      s.add_development_dependency(%q<pry-byebug>, ["~> 3"])
      s.add_development_dependency(%q<pry-doc>, ["~> 0"])
      s.add_development_dependency(%q<pry-remote>, ["~> 0"])
      s.add_development_dependency(%q<pry-rescue>, ["~> 1"])
      s.add_development_dependency(%q<pry-stack_explorer>, ["~> 0"])
    else
      s.add_dependency(%q<tzinfo-data>, [">= 0"])
      s.add_dependency(%q<bootstrap>, ["~> 4.0.0.alpha6"])
      s.add_dependency(%q<tether-rails>, [">= 0"])
      s.add_dependency(%q<octicons_helper>, [">= 0"])
      s.add_dependency(%q<turbolinks>, ["~> 5"])
      s.add_dependency(%q<jquery-rails>, ["= 4.3.1"])
      s.add_dependency(%q<rspec>, ["~> 3.5.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<juwelier>, ["~> 2.1.0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<pry>, ["~> 0"])
      s.add_dependency(%q<pry-byebug>, ["~> 3"])
      s.add_dependency(%q<pry-doc>, ["~> 0"])
      s.add_dependency(%q<pry-remote>, ["~> 0"])
      s.add_dependency(%q<pry-rescue>, ["~> 1"])
      s.add_dependency(%q<pry-stack_explorer>, ["~> 0"])
    end
  else
    s.add_dependency(%q<tzinfo-data>, [">= 0"])
    s.add_dependency(%q<bootstrap>, ["~> 4.0.0.alpha6"])
    s.add_dependency(%q<tether-rails>, [">= 0"])
    s.add_dependency(%q<octicons_helper>, [">= 0"])
    s.add_dependency(%q<turbolinks>, ["~> 5"])
    s.add_dependency(%q<jquery-rails>, ["= 4.3.1"])
    s.add_dependency(%q<rspec>, ["~> 3.5.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<juwelier>, ["~> 2.1.0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<pry>, ["~> 0"])
    s.add_dependency(%q<pry-byebug>, ["~> 3"])
    s.add_dependency(%q<pry-doc>, ["~> 0"])
    s.add_dependency(%q<pry-remote>, ["~> 0"])
    s.add_dependency(%q<pry-rescue>, ["~> 1"])
    s.add_dependency(%q<pry-stack_explorer>, ["~> 0"])
  end
end

