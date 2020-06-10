module WebGit
  require "git"
  
  class Graph
    require "action_view"
    require "action_view/helpers"
    include ActionView::Helpers::DateHelper
    attr_accessor :heads

    def initialize(git)
      @git = git
      @full_list = []
      @heads = {}
    end

    def to_hash
      
      has_changes = has_untracked_changes?
      if has_changes
        temporarily_stash_changes
      end

      draw_graph

      if has_changes
        stash_pop
      end

      @full_list
    end

    def has_untracked_changes?
      @git.diff.size > 0
    end

    def temporarily_stash_changes
      @git.add(all: true)
      stash_count = Git::Stashes.new(@git).count
      Git::Stash.new(@git, "Temporary Stash #{stash_count}")
    end

    def stash_pop
      stashes = Git::Stashes.new(@git)
      stashes.apply(0)
    end

    def draw_graph
      branches = @git.branches.local.map(&:name)
      branches.each do |branch_name|
        branch = { branch: branch_name }
        @git.checkout(branch_name)
        log_commits = build_array_of_commit_hashes
        branch[:log] = log_commits
        branch[:head] = log_commits.last[:sha]
        @full_list.push branch
      end

       @full_list.each do |branch_hash|
        head_sha = branch_hash[:head]
        branch_name = branch_hash[:branch]

        if @heads[head_sha].nil?
          @heads[head_sha] = [ branch_name ]
        else
          @heads[head_sha].push branch_name
        end
      end

    end

    def build_array_of_commit_hashes
      log_commits = []
      @git.log.sort_by(&:date).each do |git_commit_object|
        commit = {}
        commit[:sha] = git_commit_object.sha.slice(0..7)
        commit[:date] = git_commit_object.date
        commit[:formatted_date] = time_ago_in_words(git_commit_object.date)
        commit[:message] = git_commit_object.message
        commit[:author] = git_commit_object.author.name
        commit[:heads] = []
        log_commits.push commit
      end
      log_commits
    end
  end
end
