module WebGit
  require "git"
  
  class Graph
    require "action_view"
    require "action_view/helpers"
    include ActionView::Helpers::DateHelper
    attr_accessor :heads
    attr_reader :graph_order
    attr_reader :commit_order

    def initialize(git)
      @git = git
      @full_list = []
      @heads = {}
      @graph_order = {}
      @commit_order = []
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
            
      has_changes = has_untracked_changes?
      if has_changes
        temporarily_stash_changes
      end
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
      if has_changes
        stash_pop
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
            if !unique_commits.empty?
              @git.gcommit(unique_commits.first).parents.each do |gcommit|
                p "---"
                p gcommit.message + " " + gcommit.sha
                p "---"
              end
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

    def find_other_branch_names(sha, name, list)
      branch_names = []
      list.each do |branch|
        if branch[:name] != name
          log = branch[:log]
          if log.include? sha
            branch_names.push branch[:name]
          end
        end
      end
      branch_names
    end

    def find_merging_branch_name(first, last)
      list = @list
      # Start with two commit shas
      # f0c357b, 64d6e33 
      # Find branch with f0c357b, (Should already be able to find this one)
      # Find branch with 64d6e33, but NOT f0c357b
      branch1 = ""
      branch2 = ""

      list.each do |branch|
        if !branch[:log].include?(first) && branch[:log].include?(last)
          return branch[:name]
        end
      end
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
        if @graph_order.keys.include? sha
          p "FINDING OTHER BRANCH NAMES"
          # if already have a branch to, maybe DON't add another one
          other_branch_tos = @graph_order.keys.map do |other_sha|
            @graph_order[other_sha][:branches_to]
          end
          p "//////////"
          p other_branch_tos.reduce(&:+)
          p "//////////"
          if !other_branch_tos.reduce(&:+).include?(name) # name or branch_name?
            p "First one #{branch_name}"
            @graph_order[sha][:branches_to] = find_other_branch_names(sha, name, @list)
            p @graph_order[sha][:branches_to]
          else
            p "Don't you do it!"
          end
        else
          @graph_order[sha] = { branch: branch_name, branches_to: [], merge_between: [], message: commit.message, author: commit.author.name }
        end
        # Determine order of commits to draw
        if @commit_order.include? sha
          i = @commit_order.index(sha)
          @commit_order.delete_at(i)
          @commit_order.push sha
        else
          @commit_order.push sha
        end
        p "Commit: #{sha} - #{commit.message} - branch: #{branch_name}"
        # Handle Merging?
        if parents.size > 1
          @graph_order[sha][:merge_between] = parents.map{ |c| c.sha.slice(0..7)}
          p "Merge Point #{parents.map{ |c| c.sha.slice(0..7)}.join(", ")}"
          first = parents.first.sha.slice(0..7)
          last = parents.last.sha.slice(0..7)
          @graph_order[last][:branch] = find_merging_branch_name(first, last) 
        end
        
        parents.each do |parent|
          get_parents(parent.sha.slice(0..7), name, list)
        end
      else
        # It's the first commit
        if @commit_order.include? sha
          i = @commit_order.index(sha)
          @commit_order.delete_at(i)
          @commit_order.push sha
        else
          @commit_order.push sha
        end
        @graph_order[sha] = { branch: "master", branches_to: [], merge_between: [], message: commit.message, author: commit.author.name }
        p "Commit: #{sha} - #{commit.message} - branch: master"
        return
      end
    end

    # Starting info: list of branch logs => [ {name: "master", log: [...]}, {...} ]
    # Create a Hash to store commits that have been travelled to
    # For each branch,
    #   take the latest commit
    #   find each ancestor (parent) until you reach the first commit
    #     while visiting parents, save them in the Hash of all commits
    #     save the branch name, and message
    #     if a commit has more than one parent, it is a MERGE Point
    #       save the sha's of both parents with the current commit so we know which branches are being merged
    #       Merge commits also will determine which commits were made on which branch
    #     if one commit has more than one child, that is where a branch was created*

    # *create a Hash of sha's that hold the children sha's
    # Like => { "64d6e33": { children: ["bc9833b", "3c391fc"] }, { ... } }
    # After looking at all the parents on each branch

    # Need name of branch that commit started on
    #   if parent of commit has multiple children, 

    #  If parent commit has a different branch than commit of current branch,
    #    the current commit is on new branch
    def generate_children
      commits = {}
      branches = @git.branches.local.map(&:name)
      branches.each do |branch_name|
        branch = { name: branch_name }
       
        @git.checkout(branch_name)
        @git.log.each do |git_commit_object|
          sha = git_commit_object.sha.slice(0..7)
          p "Commit - #{sha} - #{git_commit_object.message} Branch: #{branch_name}"
          if !commits.keys.include? sha
            commits[sha] = { message: git_commit_object.message, children: [], branches: [ branch_name ], new_branch: false }
          elsif !commits[sha][:branches].include? branch_name
            commits[sha][:branches].push branch_name
            commits[sha][:branches] = commits[sha][:branches].uniq
          end

          if git_commit_object.parents.count > 0

            git_commit_object.parents.each do |parent|                
              
              if commits.keys.include? parent.sha.slice(0..7)
                commits[parent.sha.slice(0..7)][:children].push sha
                commits[parent.sha.slice(0..7)][:children] = commits[parent.sha.slice(0..7)][:children].uniq
                commits[parent.sha.slice(0..7)][:branches].push branch_name
                commits[parent.sha.slice(0..7)][:branches] = commits[parent.sha.slice(0..7)][:branches].uniq
                
                # if commits[sha][:branches].count  == 1 && commits[parent.sha.slice(0..7)][:branches].include?(commits[sha][:branches].first)
                #   commits[parent.sha.slice(0..7)][:new_branch] = true
                # end
                # If parent commit has More branches than current commit, the current commit starts a new branch
                # if commits[parent.sha.slice(0..7)][:branches].count > commits[sha][:branches].count
                #   commits[parent.sha.slice(0..7)][:new_branch] = true
                # end
              else
                commits[parent.sha.slice(0..7)] = { message: parent.message, children: [sha], branches: [ branch_name], new_branch: false }
              end
            end
          end
        end
      end

      # See if there are any new branches on HEAD
      # commits.keys.each do |sha|
      #   # If parent commit has More branches than current commit, the current commit starts a new branch
      #   commit = @git.gcommit(sha)
      #   commit.parents.each do |parent|
      #     parent_sha = parent.sha.slice(0..7)
      #     if commits[parent_sha][:branches].count == (commits[sha][:branches].count + 1)
      #       commits[sha][:new_branch] = true
      #       p sha
      #       p "[[[["
      #     end
      #   end
      # end
      commits
    end

    def build_backwards
      # [{"name":"master","log":["3c391fc0","f0c357bb","64d6e333","f716b366"]},{"name":"c-branch","log":["ef99623c"]},{"name":"update","log":["bc9833b9"]}]
      list = find_common_shas
      
      p "building..."
      # Why reverse?
      list.reverse.each do |branch|
      # list.each do |branch|
        name = branch[:name]
        p "Branch: #{name}"
        log = branch[:log]
        # p log.last.class
        # p @list
        # p "[][][][]"
        # p @keep_list
        if !log.empty?
          last = @git.gcommit(log.first)
          # p "Last commit #{last.sha.slice(0..7)} - #{last.message}"
          exclude_branches = {}
          # Looks like
          # { "master": [], "update": [], "c-branch": ["master", "update"]}
          # On the basis that all of master exists in c-branch currently
          get_parents(last.sha.slice(0..7), name, @list)
        end
        p "_________________________"
        p "_________________________"
        # p @graph_order
        # TODO
        # Create Hash of commits, ordered by date—
        # { "47485296": { branch: "master", branches_to: [] }, "3b3aaccf": { branch: "master", branches_to: ["b-branch"]}, "4bb66595": {},  }
        p "+++---"
      end
      p "======"
      p @commit_order = @commit_order.reverse
      # ["f62e91d6", "4bb66595", "de987471", "3b3aaccf", "47485296"]
      @commit_order.each do |sha|
        commit_info = @graph_order[sha]
        if commit_info[:branches_to].size > 0
          p "#{sha} - #{commit_info[:branch]}, branches to #{commit_info[:branches_to].join(" ,")}"
        else
          p "#{sha} - #{@graph_order[sha][:branch]}"
        end
      end
      []
    end

    # REMOVE
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
