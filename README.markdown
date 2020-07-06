# WebGit

  <% commit_order.each do |sha| %>
    <% commit_info = commits_hash[sha] %>
    <% p "_____++" %>
    <% p commit_info %>
    <% branch = commit_info[:origin_branch].first.gsub("-", "_") %>
    <% if !existing_branches.include?(branch) %>
      const <%= branch %> = gitgraph.branch("<%=branch %>")
      <% existing_branches.push branch %>
    <% end %>
    <%= branch %>.commit("<%= sha %>")
    <% if commit_info[:parents].count > 1 %>
      // Merge
      <% commit_info[:parents].each do |parent_commit| %>
        // find other branch that isn't current branch
        <% other_branch = commits_hash[parent_commit][:origin_branch].first.gsub("-", "_") %>
        <% if other_branch != branch %>
          <%= other_branch %>.merge(<%= branch %>)
          <% break %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
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
