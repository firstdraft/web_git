module WebGit
  require "git"
  class Graph
    def initialize(git)
      @git = git
      @full_list = []
    end

    def to_json
      
      had_changes = has_untracked_changes?
      if had_changes
        temporarily_stash_changes
      end

      draw_graph

      if had_changes
        stash_pop
      end

      @full_list
    end

    def to_html
      graph_json = @full_list.empty? ? to_json : @full_list
      branch_range = ( 0..(graph_json.length - 3) )
      branches = graph_json[branch_range]

      neo_thing = {}
      branches.each do |branch|
        head = branch[:head]
        neo_thing[head] = neo_thing.fetch(head, []) 
        neo_thing[head].push branch[:branch]
      end

      all_commits = graph_json.last

      output = []
      all_commits.reverse.each do |commit|
        real_commit = @git.gcommit(commit)
        name = real_commit.author.name
        commit_date = real_commit.date.strftime("%a, %d %b %Y, %H:%M %z")
        line = "<div>"
        line += '<span class="commit">'
        line += '<button class="btn btn-link sha">' + commit + "</button>"
        line += "</span> — #{commit_date}"
        if neo_thing.keys.include?(commit)
          line += " (#{neo_thing[commit].join(", ")})"
        end
        line += "</div>"
        line += "\n&emsp; | #{real_commit.message} - #{name}"
        line = "<div>\n" + line + "\n</div>"
        output.push line
      end
      output
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
        @git.log.sort_by(&:date).each do |log|
          commit = log.sha.slice(0..7)
          log_commits.push commit
        end

        branch[:log] = log_commits
        branch[:head] = log_commits.last
        @full_list.push branch
      end
      lists = @full_list.map{|l| l[:log] }
      combined_branch = { branch: "ALL", head: "_" }
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
