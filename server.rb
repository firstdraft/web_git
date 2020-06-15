
require_relative "lib/web_git/diff"
require_relative "lib/web_git/graph"
require_relative "lib/web_git/string"
require "sinatra"
require "stackprof"
require "date"
require "git"
require 'rack-mini-profiler'
require "flamegraph"
require "memory_profiler"
# class Server < Sinatra::Base
  use Rack::MiniProfiler
  Rack::MiniProfiler.config.enable_advanced_debugging_tools = true
  
  get '/log' do
    working_dir = "/Users/jelani/workspace/scrap/see-what-kinda-things-are-preinstalled-for-gitpod/.git"#File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
    g = Git.open(working_dir)
    
    graph = WebGit::Graph.new(g)
    StackProf.run(mode: :cpu, out: 'profile-log.dump') do
      graph.to_hash.to_json
    end
    #sha = commit.sha.slice(0..7)
    # commit_date = Date.parse commit.date
    # strftime("%a, %d %b %Y, %H:%M %z") -> time_ago_in_words(commit_date)
    # * 76eff73 - Wed, 11 Mar 2020 19:58:21 +0000 (13 days ago) (HEAD -> current_branch)
    #  | blease - Jelani Woods

    # " * " + sha + " - " + commit_date + " (" + time_ago_in_words(commit_date) + ") " + "\n\t| " + commit.message 
  end
  
  get "/" do
    working_dir = "#{Dir.pwd}/../../scrap/see-what-kinda-things-are-preinstalled-for-gitpod/"#File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
    g = Git.open(working_dir)
    # Update git index
    # status = g.status
    g.status.changed.each do
      g.diff.entries
    end
    # Just need the file names
    @changed_files = g.status.changed.keys
    @deleted_files = g.status.added.keys
    @untracked_files = g.status.untracked.keys
    @added_files = g.status.deleted.keys

    @statuses = [
      { name: "Changed Files:", file_list: @changed_files },
      { name: "Untracked Files:", file_list: @untracked_files },
      { name: "Deleted Files:", file_list: @deleted_files },
      { name: "Added Files:", file_list: @added_files }
    ]
    
    @current_branch = g.current_branch
    # g.branch(@current_branch).checkout # maybe?
    @status = `git status`
    @diff = g.diff
    @diff = Diff.diff_to_html(g.diff.to_s)
    last_diff = nil
    if g.log.count > 1
      last_diff = g.diff(g.log[1], "HEAD").to_s + "\n"
    end
    # @last_diff_html = Diff.last_to_html(last_diff)
    @last_diff_html = last_diff
    @branches = g.branches.local.map(&:full)
    
    logs = g.log
    @last_commit_message = logs.first.message
    @head = g.show.split("\n").first.split[1].slice(0..7)
    @list = []
    # (HEAD -> jw-non-sweet)
    # TODO show where branches are on different remotes
    # (origin/master, origin/jw-non-sweet, origin/HEAD)
    # g.branches[:master].gcommit

    graph = WebGit::Graph.new(g)
    # StackProf.start(mode: :cpu)
      @graph_hash = graph.to_hash
      @graph_branches = @graph_hash.sort do |branch_a, branch_b|
        branch_b[:log].last[:date] <=> branch_a[:log].last[:date]
      end
    g.checkout(@current_branch)
    # StackProf.stop
    # StackProf.results('status.dump')
    erb :status
  end
  
  post "/commit" do
    title = params[:title]
    description = params[:description]
    working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
    g = Git.open(working_dir)
    g.add(:all => true)  
    unless description.nil?
      title += "\n#{description}"
    end
    g.commit(title)
    redirect to("/")
  end
  
  get "/stash" do
    working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
    g = Git.open(working_dir)
    g.add(:all=>true)
    stash_count = Git::Stashes.new(g).count
    Git::Stash.new(g, "Stash #{stash_count}")
    redirect to("/")
  end
  
  post "/branch/checkout" do
    working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
    g = Git.open(working_dir)
    name = params.fetch(:branch_name).downcase.gsub(" ", "_")
    commit = params.fetch(:commit_hash)
    branches = g.branches.local.map(&:full)
    if branches.include?(name) || commit.nil? 
      g.branch(name).checkout
    else
      g.branch(name).checkout
      g.reset_hard(g.gcommit(commit))
    end
    redirect to("/")
  end
  
  # TODO make delete request somehow with the links
  post "/branch/delete" do
    working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
    g = Git.open(working_dir)
    name = params[:branch_name]
    g.branch(name).delete
    redirect to("/")
  end

  post "/push" do
    working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
    g = Git.open(working_dir)
    # TODO push to heroku eventually, multiple remotes
    # remote = params[:remote]
    # unless remote.nil?
    #   remote = g.remote remote
    #   g.push remote
    # end
    g.push
    redirect to("/")
  end

  post "/pull" do
    working_dir = File.exist?(Dir.pwd + "/.git") ? Dir.pwd : Dir.pwd + "/.."
    g = Git.open(working_dir)
    g.pull
    redirect to("/")
  end
# end
