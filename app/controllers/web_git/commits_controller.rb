module WebGit
  class CommitsController < ::ApplicationController
    skip_before_action :authenticate_user!, raise: false
    skip_before_action :force_user_sign_in, raise: false

    def create
      Dir.chdir(Rails.root) do
        `git add -A`
        `git commit -m "#{params[:title]}" -m "#{params[:description]}"`
      end

      redirect_to root_url, notice: "Changed committed."
    end

    def stash
      Dir.chdir(Rails.root) do
        `git add -A`
        # g.add(:all=>true)  
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

    def set_upstream
      current_branch = `git symbolic-ref --short HEAD`.chomp
      Dir.chdir(Rails.root) do
        @result = `git push -u origin #{current_branch}`
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
