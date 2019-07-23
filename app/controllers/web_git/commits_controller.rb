module WebGit
  class CommitsController < ::ApplicationController
    require 'git'
    skip_before_action :authenticate_user!, raise: false

    def create
      Dir.chdir(Rails.root) do
        g = Git.open(working_dir, :log => Logger.new(STDOUT))
        g.add(:all=>true) 
        # `git add -A`
        # `git commit -m "#{params[:title]}" -m "#{params[:description]}"`
        g.commit_all("#{params[:title]}\n#{params[:description]}")
      end

      redirect_to root_url, notice: "Changed committed."
    end

    def stash
      Dir.chdir(Rails.root) do
        # `git add -A`
        g = Git.open(working_dir, :log => Logger.new(STDOUT))
        g.add(:all=>true) 
        `git stash`
      end

      redirect_to root_url, notice: "Changes discarded."
    end

    def push
      Dir.chdir(Rails.root) do
        @result = `git push -f`
      end

      redirect_to root_url, notice: "Pushed to GitHub."
    end

    def pull
      current_branch = `git symbolic-ref --short HEAD`.chomp

      Dir.chdir(Rails.root) do
        @result = `git pull origin #{current_branch}`
      end

      `git fetch --prune`
      `git fetch --all`

      %x(for branch in $(git branch --all | grep '^\s*remotes' | egrep --invert-match '(:?HEAD|master)$'); do git branch --track "${branch##*/}" "$branch"; done)

      redirect_to root_url, notice: "Pulled from GitHub."
    end
  end
end
