module WebGit
  require "git"
  class Graph
    attr_accessor :heads

    def initialize(git)
      @git = git
      @full_list = []
      @heads = {}
    end

    def to_json
      
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
        log_commits = []
        @git.log.sort_by(&:date).each do |git_commit_object|
          commit = {}
          commit[:sha] = git_commit_object.sha.slice(0..7)
          commit[:date] = git_commit_object.date
          commit[:message] = git_commit_object.message
          commit[:author] = git_commit_object.author.name
          log_commits.push commit
        end

        branch[:log] = log_commits
        branch[:head] = log_commits.last[:sha]
        @full_list.push branch
      end

      lists = @full_list.map{|l| l[:log] }
      all_heads = @full_list.map do |branch_hash|
        head_sha = branch_hash[:head]
        branch_name = branch_hash[:branch]

        if @heads[head_sha].nil?
          @heads[head_sha] = [ branch_name ]
        else
          @heads[head_sha].push branch_name
        end
      end
      combined_branch = { branch: "ALL", head: "_", heads: all_heads }
      @full_list.push combined_branch
      
      log_commits = []
      (lists.count - 1).times do |i|
        log_hash = lists[i]

        log_commits = log_commits | log_hash
      end

      @full_list.push log_commits
    end

  end
end
