# WebGit

An in-browser Git GUI for your Rails project.

WebGit is a Rails Engine that provides an in-browser visual interface to a simple but effective Git workflow. For educational purposes.

## Installation


```

Add this line to your application's Gemfile:

```ruby
gem "web_git", git: "https://github.com/firstdraft/web_git"
```

And then execute:
```bash
$ bundle
```

In the directory of your Rails app run:
```bash
rails g web_git:install
```
Then `rails server` and visit `/git/status`.

## Usage

In your Rails app

```ruby
# config.ru
# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

map '/git' do
  run WebGit::Server
end

map '/' do
  run Rails.application
end
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
