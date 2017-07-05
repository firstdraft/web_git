module WebGit
  class CommitsController < ApplicationController
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

      redirect_to root_url, notice: "Pulled from GitHub."
    end
  end
end
