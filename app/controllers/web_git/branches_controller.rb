module WebGit
  class BranchesController < ApplicationController
    def create
      Dir.chdir(Rails.root) do
        if params[:commit_hash].present?
          `git checkout #{params[:commit_hash].strip.reverse.chomp("#").reverse}`
          `git checkout -b #{params[:name].parameterize}`
        else
          `git checkout -b #{params[:name].parameterize}`
        end

        redirect_to root_url, notice: "Created branch #{params[:name]}."
      end
    end

    def show
      Dir.chdir(Rails.root) do
        `git checkout #{params[:name].parameterize}`
      end

      redirect_to root_url, notice: "Switched to branch #{params[:name]}."
    end

    def destroy
      if params[:name].parameterize != "master"
        Dir.chdir(Rails.root) do
          `git branch -D #{params[:name].parameterize}`
        end

        redirect_to root_url, notice: "Deleted branch #{params[:name]}."
      else
        redirect_to root_url, alert: "It's not a great idea to delete the master branch. If you really want to, you're on your own!"
      end
    end
  end
end
