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

    def list_all_shas
      @list = []
      branches = @git.branches.local.map(&:name)
      branches.each do |branch_name|
        branch = { name: branch_name }
        @git.checkout(branch_name)
        log = []
        @git.log.each do |git_commit_object|
          sha = git_commit_object.sha.slice(0..7)
          log.push sha
        end
        branch[:log] = log
        @list.push branch
      end
    end

    def find_common_shas
      list_all_shas
      @keep_list = @list
      new_list = []
      # Only need to compare to the master branch?
      # master = @list
      @list.each do |branch|
        if branch[:name] == "master"
          current_log = branch[:log]
          other_branches = @list - [ branch ]
          new_list.push({name: "master", log: current_log})
          p "Current Branch: #{branch[:name]}"
          p "================================"
          other_branches.each do |other_branch|
            p "Other Branch: #{other_branch[:name]}"
            new_branch = { name: other_branch[:name]}
            branch_log = other_branch[:log]
            
            p "Current Log: #{current_log}"
            p "Branch Log: #{branch_log}"
            unique_commits = branch_log - current_log
            p "Unique Log: #{unique_commits}"
            new_branch[:log] = unique_commits
            p "Parents"
            @git.gcommit(unique_commits.first).parents.each do |gcommit|
              p "---"
              p gcommit.message + " " + gcommit.sha
              p "---"
            end
            new_list.push new_branch
            # current_log.each do |sha|
            # end
          end
          p "================================"
          puts "\n" * 3
        end
      end
      new_list
    end

    def is_unique_sha?(sha, name, list)
      # p "IS UNIQUE"
      list.each do |branch|
        if branch[:name] != name
          # p "Branch name: #{branch[:name]}"
          # p "(real)current: " + name
          log = branch[:log]
          # p "log"
          # p log
          # p " - " + sha
          if log.include? sha
            return false
          end
        end
      end
      true
    end

    def get_parents(sha, name, list)
      commit = @git.gcommit(sha)
      parents = commit.parents
      # if parents.size > 1 then it's a merge commit
      if parents.size > 0
        # Find out if sha is unique, 
        # If not, branch is current
        # Else branch is 'master'
        branch_name = "master"
        # p "SHA CLASSS"
        # p sha.class
        # p "#{sha}"
        # puts "\n" * 3
        # p "====uniqueness====="
        if is_unique_sha?(sha, name, @list)
          # p "IS UNIQUE"
          branch_name = name
        end
        # p "====uniqueness====="
        # puts "\n" * 3
        
        p "Commit: #{sha} - #{commit.message} - branch: #{branch_name}"
        if parents.size > 1
          p "Merge Point #{parents.map{ |c| c.sha.slice(0..7)}.join(", ")}"
        end
        
        parents.each do |parent|
          get_parents(parent.sha.slice(0..7), name, list)
        end
      else
        # It's the first commit
        p "Commit: #{sha} - #{commit.message}"
        return
      end
    end

    def build_backwards
      # [{"name":"master","log":["3c391fc0","f0c357bb","64d6e333","f716b366"]},{"name":"c-branch","log":["ef99623c"]},{"name":"update","log":["bc9833b9"]}]
      list = find_common_shas
      
      p "building..."
      list.reverse.each do |branch|
        name = branch[:name]
        p "Branch: #{name}"
        log = branch[:log]
        # p log.last.class
        # p @list
        # p "[][][][]"
        # p @keep_list
        last = @git.gcommit(log.first)
        # p "Last commit #{last.sha.slice(0..7)} - #{last.message}"
        get_parents(last.sha.slice(0..7), name, @list)

        # TODO
        # Create Hash of commits, ordered by date—
        # { "47485296": { branch: "master", branches_to: [] }, "3b3aaccf": { branch: "master", branches_to: ["b-branch"]}, "4bb66595": {},  }
        p "+++---"
      end
      p "======"

      []
    end

    def tree_traversal
      tree = []
      @git.log.each do |git_commit_object|
        sha = git_commit_object.sha.slice(0..7)
        parents = git_commit_object.parents.map{ |parent| { sha: parent.sha, message: parent.message}}
        git_tree = @git.gtree(git_commit_object.sha)
        children = git_tree.children#.map{ |child| { sha: child.sha, message: child.message}}
        object = {message: git_commit_object.message, sha: sha, parents: parents, children: children}
        tree.push object 
      end
      tree
    end

    def to_array
      # Each element is a branch log
      #   Each branch log has a starting commit and ending commit
      #   Each branch log only has commits that are unique to that branch
      lists = @full_list.map{|l| l[:log] }
      combined_branch = { branch: "ALL", head: "_" }
      
      
      log_commits = []
      (lists.count - 1).times do |i|
        log_hash = lists[i]

        log_commits = log_commits | log_hash
      end
      combined_branch[:log] = log_commits
      log_commits
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
        commit[:branch_name] = @git.current_branch
        commit[:heads] = []
        log_commits.push commit
      end
      log_commits
    end
  end
end
