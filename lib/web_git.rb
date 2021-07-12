
require "web_git/version"

module WebGit
  require "active_support"
  require "web_git/diff"
  require "web_git/graph"
  require "web_git/heroku"
  require "web_git/string"
  require "sinatra"
  require "date"
  require "git"
  class Server < Sinatra::Base
    enable :sessions

    get '/log' do
      graph = WebGit::Graph.new(git)
      graph.to_hash.to_json
      #sha = commit.sha.slice(0..7)
      # commit_date = Date.parse commit.date
      # strftime("%a, %d %b %Y, %H:%M %z") -> time_ago_in_words(commit_date)
      # * 76eff73 - Wed, 11 Mar 2020 19:58:21 +0000 (13 days ago) (HEAD -> current_branch)
      #  | blease - Jelani Woods

      # " * " + sha + " - " + commit_date + " (" + time_ago_in_words(commit_date) + ") " + "\n\t| " + commit.message 
    end

    get "/" do
      initialize_flash
      clear_flash
      # Update git index
      git.status.changed.each do
        git.diff.entries
      end
      status = git.status
      # Just need the file names
      @changed_files = status.changed.keys
      @deleted_files = status.added.keys
      @untracked_files = status.untracked.keys
      @added_files = status.deleted.keys

      @statuses = [
        { name: "Changed Files:", file_list: @changed_files },
        { name: "Untracked Files:", file_list: @untracked_files },
        { name: "Deleted Files:", file_list: @deleted_files },
        { name: "Added Files:", file_list: @added_files }
      ]
      
      @current_branch = git.current_branch
      # g.branch(@current_branch).checkout # maybe?
      # TODO use git gem for status
      @status = `git status`
      @diff = git.diff
      @diff = Diff.diff_to_html(git.diff.to_s)
      if git.log.count > 1
        last_diff = git.diff("HEAD~1", "HEAD").to_s + "\n"
        @last_diff_html = Diff.last_to_html(last_diff)
      end
      @last_diff_html = ""
      @branches = git.branches.local.map(&:full)
      
      logs = git.log
      @last_commit_message = logs.first.message
      @head = git.show.split("\n").first.split[1].slice(0..7)
      @list = []
      # (HEAD -> jw-non-sweet)
      # TODO show where branches are on different remotes
      @remotes = git.remotes.map {|remote| "#{remote.name}: #{remote.url}"  }
      # (origin/master, origin/jw-non-sweet, origin/HEAD)
      # git.branches[:master].gcommit

      graph = WebGit::Graph.new(git)
      @graph_hash = graph.to_hash
      @cli_graph_interactive = graph.cli_graph
      @graph_branches = @graph_hash.sort do |branch_a, branch_b|
        branch_b[:log].last[:date] <=> branch_a[:log].last[:date]
      end

      # TODO heroku stuff
      @heroku_auth = WebGit::Heroku.whoami
      erb :status
    end

    post "/commit" do
      title = params[:title]
      description = params[:description]

      # TODO validate commit message
      if title.nil? || title.gsub(" ", "").length == 0
        session[:alert] = "You need to make a commit message."
        redirect to("/")
      end

      unless description.nil?
        title += "\n#{description}"
      end

      safe_git_action(:commit, args: title, notice: "Commit created successfully", alert: "Failed to create commit")
      redirect to("/")
    end

    get "/stash" do
      safe_git_action(:stash, notice: "Changes stashed.", alert: "Failed to stash changes")
      redirect to("/")
    end

    post "/branch/checkout/new" do
      # TODO validate branch name
      name = params.fetch(:branch_name).downcase.gsub(" ", "_")
      commit = params.fetch(:commit_hash)

      safe_git_action(:checkout, args: name, notice: "Branch #{name}, created successfully.", alert: "Failed to create branch")
      safe_git_action(:reset_hard, args: commit, alert: "Failed to checkout branch at #{commit}")
      redirect to("/")
    end

    post "/branch/checkout" do
      name = params.fetch(:branch_name).downcase.gsub(" ", "_")

      safe_git_action(:checkout, args: name, notice: "Switched to branch: #{name} successfully.", alert: "Failed to switch branch")
      redirect to("/")
    end

    # TODO make delete request somehow with the links
    post "/branch/delete" do
      name = params.fetch(:branch_name).downcase.gsub(" ", "_")

      safe_git_action(:delete, args: name, notice: "Deleted branch: #{name} successfully.", alert: "Failed to delete branch")
      redirect to("/")
    end

    post "/push" do
      # TODO push to heroku eventually, multiple remotes

      safe_git_action(:push, notice: "Pushed to GitHub successfully.", alert: "Failed to push")
      redirect to("/")
    end

    post "/pull" do
      safe_git_action(:pull, notice: "Pulled successfully.", alert: "Git Pull failed")
      redirect to("/")
    end

    post "/heroku/login" do
      email = params[:heroku_email]
      password = params[:heroku_password]

      begin
        WebGit::Heroku.authenticate(email, password)
        set_flash(:notice, "Successfully logged into Heroku.")
      rescue => exception
        set_flash(:alert, "There was a problem logging into Heroku. #{exception.message}")
      end
      redirect to("/")
    end

    protected

    def git
      working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
      @git ||= Git.open(working_dir)
    end

    def safe_git_action(method, **options)
      begin
        case method
        when :push
          git.push('origin', git.current_branch)
        when :pull
          git.pull
        when :stash
          git.add(all: true)
          stash_count = Git::Stashes.new(git).count
          Git::Stash.new(git, "Stash #{stash_count}")
        when :commit
          git.add(all: true)  
          git.commit(options[:args])
        when :checkout
          git.branch(options[:args]).checkout
        when :reset_hard
          commit = git.gcommit(options[:args])
          git.reset_hard(commit)
        when :delete
          git.branch(options[:args]).delete          
        end
        set_flash(:notice, options[:notice])
      rescue Git::GitExecuteError => exception
        alert_message = "#{options[:alert]}: #{exception.message.split("\n").last}"
        set_flash(:alert, alert_message)
      end
    end

    def set_flash(name, message)
      session[name] = message
    end

    def clear_flash
      session[:alert] = nil
      session[:notice] = nil
    end

    def initialize_flash
      @alert = session[:alert]
      @notice = session[:notice]
    end
  end
end
